package Kynetx::Endpoints;
# file: Kynetx/Endpoints.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Util qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Request;
use Kynetx::Rules;
use Kynetx::Actions;
use Kynetx::Json;
use Kynetx::Predicates::Amazon::SNS::Response qw(:all);
use Kynetx::Endpoints::KNS qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(

) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    Kynetx::Util::config_logging($r);

    my $logger = get_logger();

    $r->content_type('text/javascript');


    $logger->debug("------------------------------ begin endpoint evaluation -----------------------------");
    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my ($endpoint,$medium,$rid);
    my $ken = '';

    ($endpoint,$medium,$rid,$ken) = $r->path_info =~ m!/([a-z+_]+)/?([a-z+_]+)?/?([A-Za-z0-9_;]*)/?([A-Z0-9-]*)?/?!;


 # Set to be the same now one.  This will pass back the rid to the runtime
    #$eid = $rid;
    $logger->debug("processing directive for $endpoint/$medium on rulesets $rid and KEN $ken");

    Log::Log4perl::MDC->put('site', $rid);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    # store these for later logging
    $r->subprocess_env(ENDPOINT => $endpoint);
    $r->subprocess_env(MEDIUM => $medium);
    $r->subprocess_env(RIDS => $rid);

    # at some point we need a better dispatch function
    if($endpoint eq 'kns' ) {
      $logger->debug("kns endpoint");
      Kynetx::Endpoints::KNS::eval_kns($r,$endpoint,$medium,$rid);

    } else {
        $logger->debug("undefined endpoint");
        Kynetx::Util::request_dump($r);
    }

    return Apache2::Const::OK;
}



1;
