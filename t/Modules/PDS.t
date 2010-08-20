#!/usr/bin/perl -w

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
use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString max => 100;
use Test::Deep qw(
    cmp_deeply
    superbagof
    bag
    superhashof
    subhashof
    subbagof
    re
    ignore
    array_each
);
use Data::Dumper;
use LWP::UserAgent;
use LWP::Simple;
use JSON::XS;
use Apache::Session::Memcached;

use APR::URI;
use Cache::Memcached;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);
my $logger = get_logger();

use Kynetx::Test;
use Kynetx::Datasets;
use Kynetx::JavaScript;
use Kynetx::Parser;
use Kynetx::Configure;
use Kynetx::FakeReq;
use Kynetx::Environments;
use Kynetx::Rules;
use Kynetx::Predicates::OData;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Modules::PDS::KEN qw/:all/;

Kynetx::Configure::configure();
my $ck = "d528c1b5f7446c9322de70fbcaea1bb2";

# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $rid = 'PDStest';
my $results;
my $tcount=0;

my $r = Kynetx::Test::configure();
my $session = process_session($r,$ck);
my $req_info = Kynetx::Test::gen_req_info();
my $rule_env = Kynetx::Test::gen_rule_env();

my $preds = Kynetx::Modules::PDS::get_predicates();
my @pnames = keys(%{$preds});
my $args;
my $expected;
my $got;
my $test_name;
my $pds_path;
my $json;
my $description;
my $function;

sub test_pds {
    my ($pred,$req_info,$session,$args) = @_;
    $tcount++;
    return &{$preds->{$pred}}($req_info, $rule_env,$args);
};

# Predicates
$description = "true()";
$args = [];
$results = test_pds('true',$req_info,$session,$args);
$logger->debug("Results: ", sub {Dumper($results)});
$expected = 1;
cmp_deeply($results,$expected,$description);

$description = "false()";
$args = [];
$results = test_pds('false',$req_info,$session,$args);
$logger->debug("Results: ", sub {Dumper($results)});
$expected = 0;
cmp_deeply($results,$expected,$description);




#### Module function requests

# GET
$function = "get";

$args = {"path" => 'medical.doctor'};
$json = Kynetx::Modules::PDS::run_function($req_info,$session,$function,$args);
cmp_deeply($json,1,"True");
$tcount++;




plan tests => $tcount;

1;


