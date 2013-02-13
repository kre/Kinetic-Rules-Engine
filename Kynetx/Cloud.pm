package Kynetx::Cloud;

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
	my $req = Apache2::Request->new($r);
	my @params = $req->param;

	$r->content_type('text/javascript');

	$logger->debug(
"\n\n------------------------------ begin ID evaluation with CLOUDID API---------------------"
	);
	$logger->debug("Initializing memcached");
	Kynetx::Memcached->init();

	my ( $domain, $eventtype, $eid, $rids, $id_token );
	$r->subprocess_env( START_TIME => Time::HiRes::time );

# path looks like: /sky/{event|flush}/{version|<id_token>}/<eid>?_domain=...&_name=...&...

	my @path_components = split( /\//, $r->path_info );
  my $method;
  my $rid;
  my $eid = '';
  my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);

	if ( Kynetx::Configure::get_config('RUN_MODE') eq 'development' ) {

		# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
		my $test_ip = Kynetx::Configure::get_config('TEST_IP');
		$r->connection->remote_ip($test_ip);
		$logger->debug( "In development mode using IP address ",
			$r->connection->remote_ip() );
	}


	# store these for later logging
	if ( $id_token eq 'version' ) {
		$logger->debug("returning version info for Sky event API");
		Kynetx::Version::show_build_num($r);
		exit();
	}
	elsif ( $path_components[1] eq 'flush' ) {

	}	else {
    print join " ", @path_components;

	}
  my $heartbeat = "// KNS " . gmtime() . " (" . Kynetx::Util::get_hostname() . ")\n";
  print $heartbeat;
#    $logger->info("Rids for $domain/$eventtype: ", sub {Kynetx::Rids::print_rids($rid_list)});

	Kynetx::Request::log_request_env( $logger, $req_info );


	return Apache2::Const::OK;
}


1;
