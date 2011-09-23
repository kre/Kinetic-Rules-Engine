package Kynetx::Response;
# file: Kynetx/Response.pm
# file: Kynetx/Predicates/Referers.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Kynetx::Session qw/session_cleanup/;
use Kynetx::Log;
use Kynetx::Directives;


sub respond {
  my ($r, $req_info, $session, $js, $realm) = @_;

  my $logger = get_logger();


  # put this in the logging DB
  Kynetx::Log::log_rule_fire($r,
			     $req_info,
			     $session
			    );


  # finish up
  Kynetx::Session::session_cleanup($session,$req_info);

  # return the JS load to the client
  $logger->info("$realm processing finished");
  $logger->debug("__FLUSH__");

  $logger->debug("Called with ", $r->the_request);

  # heartbeat string (let's people know we returned something)
  my $heartbeat = "// KNS " . gmtime() . "\n";

  # this is where we return the JS
  if ($req_info->{'understands_javascript'}) {
    $logger->debug("Returning javascript from evaluation");
    print $heartbeat, $js;
  } else {
    $logger->debug("Returning directives from evaluation");

    print $heartbeat, Kynetx::Directives::gen_directive_document($req_info);
  }

}

1;
