package Kynetx::Sky;

# file: Kynetx/Sky.pm
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc.
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#

use strict;

#use warnings;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
$Data::Dumper::Indent = 1;

use JSON::XS;

use Kynetx::Version;
use Kynetx::Events;
use Kynetx::Session;
use Kynetx::Memcached;
use Kynetx::Dispatch;
use Kynetx::Metrics::Datapoint;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
	all => [
		qw(
		  )
	]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

sub handler {
	my $r = shift;

	# configure logging for production, development, etc.
	Kynetx::Util::config_logging($r);

	my $logger = get_logger();
	my $metric = new Kynetx::Metrics::Datapoint();
	$metric->start_timer();
	$metric->series("sky");
	$metric->path($r->path_info);

	$r->content_type('text/javascript');

	$logger->debug(
"\n\n------------------------------ begin EVENT evaluation with SKY API---------------------"
	);
	$logger->debug("Initializing memcached");
	Kynetx::Memcached->init();

	my ( $domain, $eventtype, $eid, $rids, $id_token );

	$r->subprocess_env( START_TIME => Time::HiRes::time );

# path looks like: /sky/{event|flush}/{version|<id_token>}/<eid>?_domain=...&_name=...&...

	my @path_components = split( /\//, $r->path_info );

	# 0 = "sky"
	# 1 = "event|flush"
	$id_token = $path_components[2];
	$eid = $path_components[3] || '';

	# optional...usually passed in as parameters
	$domain    = $path_components[4];
	$eventtype = $path_components[5];

	$metric->eid($eid);
	$metric->event(
		{
			'domain' => $domain,
			'type'   => $eventtype
		}
	);
	$metric->token($id_token);

	if ( Kynetx::Configure::get_config('RUN_MODE') eq 'development' ) {

		# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
		my $test_ip = Kynetx::Configure::get_config('TEST_IP');
		$r->connection->remote_ip($test_ip);
		$logger->debug( "In development mode using IP address ",
			$r->connection->remote_ip() );
	}

	# build the request data structure. No RIDs yet. (undef)
	my $req_info = Kynetx::Request::build_request_env(
		$r, $domain, $rids,
		$eventtype,
		$eid,
		{
			'api'      => 'sky',
			'id_token' => $id_token
		}
	);

	# use the calculated values...
	$domain    = $req_info->{'domain'};
	$eventtype = $req_info->{'eventtype'};
	
	unless ($metric->event) {
		$metric->event(
			{
				'domain' => $domain,
				'type'   => $eventtype
			}
		);		
	}

	# store these for later logging
	$r->subprocess_env( DOMAIN    => $domain );
	$r->subprocess_env( EVENTTYPE => $eventtype );
	Log::Log4perl::MDC->put( 'site', "[no rid]" );
	Log::Log4perl::MDC->put( 'rule', '[global]' );    # no rule for now...
	Log::Log4perl::MDC->put( 'eid',  $eid );          # identify event

	# get a session
	$logger->info( "KBX token ", $req_info->{'id_token'} );

#    my $session = Kynetx::Session::process_session($r, $req_info->{'kntx_token'});
	my $session =
	  Kynetx::Session::process_session( $r, undef, $req_info->{'id_token'} );

	# just show the version and exit if that's what's called for
	if ( $id_token eq 'version' ) {
		$logger->debug("returning version info for Sky event API");
		Kynetx::Version::show_build_num($r);
		exit();
	}
	elsif ( $path_components[1] eq 'flush' ) {

		# /sky/flush/<id_token>...
		flush_ridlist_cache( $r, $session );
		exit();
	}

	# error checking for event domains and types
	# we need to set the RID to a global rid???
	unless ( $domain =~ m/[A-Za-z+_]+/ ) {
		Kynetx::Errors::raise_error(
			$req_info,
			'error',
			"malformed event domain $domain; must match [A-Za-z+_]+",
			{
				'genus'   => 'system',
				'species' => 'malformed event'
			}
		);
	}

	unless ( $eventtype =~ m/[A-Za-z+_]+/ ) {
		Kynetx::Errors::raise_error(
			$req_info,
			'error',
			"malformed event type $eventtype; must match [A-Za-z+_]+",
			{
				'genus'   => 'system',
				'species' => 'malformed event'
			}
		);
	}

	my ( $rid_list, $unfiltered_rid_list, $domain_test );

	# if rids were given in request, just use them. Otherwise, calculate them
	if ( defined $req_info->{'_rids'} ) {
		$rid_list = $req_info->{'rids'};

		# this likely takes too long...or maybe not...

		foreach my $rid_info ( @{$rid_list} ) {

			my $rid = $rid_info->{'rid'};
			$metric->tag($rid);
			my $ruleset =
			  Kynetx::Repository::get_rules_from_repository( $rid_info,
				$req_info, $rid_info->{'kinetic_app_version'} );

			my $dispatch_list =
			  Kynetx::Dispatch::process_dispatch_list( $rid, $ruleset );

			foreach my $d ( @{ $dispatch_list->{'domains'} } ) {
				$domain_test->{$rid}->{'domain'}->{$d} = 1;
			}
		}

	}
	else {

		$unfiltered_rid_list =
		  Kynetx::Dispatch::calculate_rid_list( $req_info, $session );

  # this can be a big list...
  # $logger->error("Rids for $id_token: ", sub {Dumper ($unfiltered_rid_list)});

		# filter $unfiltered_rid_list for saliant rulesets

		$rid_list = $unfiltered_rid_list->{$domain}->{$eventtype} || [];

		$domain_test = $unfiltered_rid_list->{'ridlist'};

#      $logger->error("Domain test for $id_token: ", sub {Dumper ($domain_test)});

		$req_info->{'rids'} = $rid_list;

	}

#    $logger->info("Rids for $domain/$eventtype: ", sub {Kynetx::Rids::print_rids($rid_list)});

	Kynetx::Request::log_request_env( $logger, $req_info );

	my $ev = Kynetx::Events::mk_event($req_info);

	my $schedule = Kynetx::Scheduler->new();

	$logger->debug("processing event $domain/$eventtype");

	my $hostname;
	if ( $domain eq 'web' ) {
		my $parsed_url =
		  APR::URI->parse( $req_info->{'pool'}, $req_info->{'url'} );
		$hostname = $parsed_url->hostname;
	}

	foreach my $rid_info ( @{$rid_list} ) {

		# check dispatch if domain is web and rids weren't specified
		my $rid = $rid_info->{'rid'};
		if (   $domain eq 'web'
			&& $eventtype eq 'pageview'
			&& !$req_info->{'explicit_rids'}
			&& !$domain_test->{$rid}->{'domains'}->{$hostname} )
		{
			$logger->debug(
				"Skipping $rid due to domain mismatch for $hostname");
			next;
		}
		my $ev_metric = new Kynetx::Metrics::Datapoint(
			{
				'rid'    => $rid,
				'eid'    => $eid,
				'series' => 'sky-process-event'
			}
		);
		$ev_metric->start_timer();		
		$ev_metric->token( $id_token );

		eval {
			$logger->debug("Processing event for $rid");
			Kynetx::Events::process_event_for_rid( $ev, $req_info, $session,
				$schedule, $rid_info );
		};
		$ev_metric->stop_and_store();
		if ($@) {

		# this might lead to circular errors if raising an error causes an error
		# Kynetx::Errors::raise_error($req_info,
		# 			    'error',
		# 			    "Process event failed for rid ($rid): $@",
		# 			    {'genus' => 'system',
		# 			     'species' => 'unknown'
		# 			    }
		# 			   );
			$logger->error("Process event failed for rid ($rid): $@");

			# special handling follows
			if ( $@ =~ m/mongodb/i ) {

				#Kynetx::MongoDB::init();
				$logger->error(
					"Caught MongoDB error, reset connection disabled");
			}

		}
	}

	$logger->debug("Schedule complete");
	my $dd       = Kynetx::Response->create_directive_doc( $req_info->{'eid'} );
	my $js       = '';
	my $s_metric = new Kynetx::Metrics::Datapoint(
		{
			'eid'    => $req_info->{'eid'},
			'series' => 'sky-event-schedule'
		}
	);
	$s_metric->rid( $domain . "/" . $eventtype );
	$s_metric->token( $id_token);
	$s_metric->start_timer();
	$js .= eval {
		Kynetx::Rules::process_schedule( $r, $schedule, $session, $eid,
			$req_info, $dd, $s_metric );
	};
	$s_metric->stop_and_store();

	if ($@) {

		# Kynetx::Errors::raise_error($req_info,
		# 				  'error',
		# 				  "Process event schedule failed: $@",
		# 				    {'genus' => 'system',
		# 				     'species' => 'unknnown'
		# 				    }
		# 				 );
		$logger->error("Process event schedule failed: $@");

		# special handling follows
		if ( $@ =~ m/mongodb/i ) {

			#Kynetx::MongoDB::init();
			$logger->error("Caught MongoDB error, reset connection disabled");
		}
	}

	my $r_metric = new Kynetx::Metrics::Datapoint(
		{
			'eid'    => $req_info->{'eid'},
			'series' => 'sky-event-respond'
		}
	);

	Kynetx::Response::respond( $r, $req_info, $session, $js, $dd, "Event" );
	$metric->stop_and_store();

	return Apache2::Const::OK;
}

sub flush_ridlist_cache {
	my ( $r, $session ) = @_;

	Kynetx::Dispatch::clear_rid_list($session);

	$r->content_type('text/html');
	my $msg = "RID List flushed for " . Kynetx::Session::session_id($session);
	print "<title>$msg</title><h1>$msg</h1>";

}

1;
