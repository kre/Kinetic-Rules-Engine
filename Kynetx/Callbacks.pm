package Kynetx::Callbacks;
# file: Kynetx/Callbacks.pm
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

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
process_callbacks
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



use Log::Log4perl qw(get_logger :levels);
use Data::UUID;

use Kynetx::Session qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Repository;
use Kynetx::Request qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Environments qw(:all);
use Kynetx::Postlude;



sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    Log::Log4perl::MDC->put('site', '[global]');
    Log::Log4perl::MDC->put('rule', '[callbacks]');

    $r->content_type('text/javascript');

    # set up memcached
    Kynetx::Memcached->init();

    my ($rids) = $r->path_info =~ m!/([A-Za-z0-9_;]*)/?!;

    my $logger = get_logger();

    if($rids eq 'version' ) {
    # store these for later logging
	$r->subprocess_env(METHOD => 'version');
	show_build_num($r);
    } else {
	process_action($r, $rids);
    }

    $logger->debug("__FLUSH__");

    return Apache2::Const::OK;
}


1;


sub process_action {
    my ($r, $rids, $method) = @_;

    my $logger = get_logger();


    $r->subprocess_env(START_TIME => Time::HiRes::time);


    # get a session hash from the cookie or build a new one
    my $session = process_session($r);

    # build initial env
    my $req_info = Kynetx::Request::build_request_env($r, 'callback', $rids);
#    my $session_lock = "lock-" . Kynetx::Session::session_id($session);
#    if ($req_info->{'_lock'}->lock($session_lock)) {
#        $logger->debug("Session lock acquired for $session_lock");
#    } else {
#        $logger->warn("Session lock request timed out for ",sub {Dumper($rids)});
#    }

#    my $ug = new Data::UUID;
#    my $path_info = $r->uri;
#     my %request_info = (
# 	host => $r->connection->get_remote_host,
# 	caller => $r->headers_in->{'Referer'},
# 	now => time,
# 	site => $path_info =~ m#/log|callback/([^/]+)#,
# 	hostname => $r->hostname(),
# 	ip => $r->connection->remote_ip(),
# 	txn_id => $ug->create_str(),
# 	);

    Log::Log4perl::MDC->put('site', $req_info->{'site'});

    my $req = Apache2::Request->new($r);

    my $rid_info = mk_rid_info($req_info, $req->param('rid'));

#    Kynetx::Request::log_request_env($logger, $req_info);

    process_callbacks(get_ruleset($rid_info,
				  $req_info),
		      $req->param('rule'),
		      $req->param('sense'),
		      $req->param('type'),
		      $req->param('element'),
		      $req_info,
		      $session) if $req_info->{'rid'};



    # store these for later logging
    $r->subprocess_env(METHOD => 'callback');
    $r->subprocess_env(RIDS => $req_info->{'site'});
    $r->subprocess_env(SITE => $req_info->{'site'});
    $r->subprocess_env(RID => get_rid($req_info->{'rid'}));

    # make sure we use the one sent, not the one for this interaction
    $r->subprocess_env(TXN_ID => $req->param('txn_id'));
    $r->subprocess_env(CALLER => $req_info->{'caller'});

    my $sid = Kynetx::Session::session_id($session);
    $r->subprocess_env(SID => $sid);

    $r->subprocess_env(IP => $req_info->{'ip'});
    $r->subprocess_env(REFERER => $req_info->{'referer'});
    $r->subprocess_env(TITLE => $req_info->{'title'});
    $r->subprocess_env(URL => $req->param('url'));
    $r->subprocess_env(SENSE => $req->param('sense'));
    $r->subprocess_env(TYPE => $req->param('type'));
    $r->subprocess_env(ELEMENT => $req->param('element'));
    $r->subprocess_env(RULE_NAME => $req->param('rule'));

    # set values of context sensitive field
    if($req->param('type') eq 'click') {
      $r->subprocess_env(CB_INFO => $req->param('url'));
    } elsif ($req->param('type') eq 'explicit') {
      $r->subprocess_env(CB_INFO => $req->param('message'));
    }elsif ($req->param('type') eq 'annotated_search_results') {
      $r->subprocess_env(CB_INFO => $req->param('element'));
    }

    $logger->debug("Finish time: ", time, " Start time: ", $r->subprocess_env('START_TIME'));

    if($req->param('url')){
	my $url = $req->param('url');
	$logger->debug("Redirecting to ", $url);
	print "window.location.replace('$url');";


    }

    $logger->info("Processing callback for RID " . get_rid($req_info->{'rid'}) . " and rule " . $req->param('rule'));

    $r->subprocess_env(TOTAL_SECS => Time::HiRes::time -
	$r->subprocess_env('START_TIME'));

    session_cleanup($session);

}

# retrieve callback info for expression
sub get_ruleset {
    my ($rid, $req_info) = @_;

    my $logger = get_logger();
    $logger->debug("[callbacks] Getting ruleset for $rid");

    return Kynetx::Repository::get_rules_from_repository($rid, $req_info);

}

sub process_callbacks {
    my ($ruleset, $rule_name, $sense, $type, $value, $req_info, $session) = @_;

    my $logger = get_logger();

    foreach my $rule (@{ $ruleset->{'rules'} }) {
	if($rule->{'name'} eq $rule_name) {
	    $logger->debug("Processing callbacks for $rule_name");
	    foreach my $cb (@{ $rule->{'callbacks'}->{$sense}} ) {
		if($cb->{'type'} eq $type &&
		   $cb->{'value'} eq $value &&
		   defined $cb->{'trigger'}
		  ) {
		    $logger->debug("Evaluating callback triggered persistent expr");
#		    $logger->debug(Dumper($cb->{'trigger'}));
		    Kynetx::Postlude::eval_persistent_expr($cb->{'trigger'},
							  $session,
							  $req_info,
							  empty_rule_env(),
							  $rule_name);
		}
	    }
	    last; # only one rule with that name
	}
    }

}





