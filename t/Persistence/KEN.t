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
use Test::Deep;
use Data::Dumper;
use MongoDB;
use Apache::Session::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::KEN qw/:all/;
use Kynetx::Persistence::KToken qw(:all);
my $logger = get_logger();
my $num_tests = 0;
my $result;


# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();
my $ken_re = qr([0-9|a-f]{16});
my $ken;
my $description;

my $rid = "cs_test";
my $frid = "not_cs_test";
my $static_token = "247fe820-1782-012e-dbbc-525445a0543c";
my $srid = "token_tests";
my $ubx_bad = "TESTTOKEN_NEVERDELETE";
my $ubx_ken = "4d544a412c15431307000001";
my $temp_token;
my $tsession;

my $r = new Kynetx::FakeReq();
$r->_delete_session();
$logger->debug("r: ", sub {Dumper($r)});

my $session = process_session($r);

$description = "No token. Create a new KEN";
my $nken = Kynetx::Persistence::KEN::get_ken($session,$srid);
testit($nken,re($ken_re),$description);
my $key = {
  "ken" => $nken
};
my $got = Kynetx::MongoDB::get_value("tokens",$key);


$temp_token = $got->{'ktoken'};
$tsession = $got->{'endpoint_id'};

diag $temp_token;
diag $tsession;

# Set the session, find a KEN
$r = new Kynetx::FakeReq();
$r->_set_session($tsession);

$session = process_session($r);
$description = "Find KEN from session";
my $session_ken = Kynetx::Persistence::KEN::get_ken($session,$frid);
$logger->debug("Ken session: ",$session_ken);
testit($session_ken,re($ken_re),$description,0);


# Ignore the session, just use the UBX
$description = "Check the token database for ($static_token)";
$r = new Kynetx::FakeReq();
$r->_set_ubx_token($static_token);
$session = process_session($r);
$ken = Kynetx::Persistence::KEN::get_ken($session,$frid);
testit($ken,$ubx_ken,$description);

diag " ";
diag " ";
diag " ";

$tsession = Kynetx::Session::session_id($session);
diag "$tsession";
# Ignore the session, just use the UBX
$description = "Check the token database for ($static_token)";
$r = new Kynetx::FakeReq();
$r->_set_ubx_token($static_token);
$session = process_session($r,$tsession);
$ken = Kynetx::Persistence::KEN::get_ken($session,$frid);
testit($ken,$ubx_ken,$description);

#$description = "Clean up and delete KEN";
#Kynetx::Persistence::KEN::delete_ken($nken);
#$got = Kynetx::MongoDB::get_value("kens",$key);
#testit($got,undef,$description);

sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    cmp_deeply($got,$expected,$description);
}
ENDY:
session_cleanup($session);

plan tests => $num_tests;
1;