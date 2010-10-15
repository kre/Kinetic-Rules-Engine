package Kynetx::Response;
# file: Kynetx/Response.pm
# file: Kynetx/Predicates/Referers.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
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
  session_cleanup($session);

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
