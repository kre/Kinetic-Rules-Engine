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
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::KEN qw/:all/;
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

my $r = new Kynetx::FakeReq();

my $session = process_session($r);
my $ken = Kynetx::Persistence::KEN::has_ken($session);
#Kynetx::Persistence::KEN::_peg_ken_to_session($session,$ken);
# after this section we don't care about the session_id because we will be
# using the session object

my $ck_old = session_id($session);

# Make sure that our test KEN exists in the database
my $valid = Kynetx::Persistence::KEN::_validate_ken($ken);
testit($valid,1,"Test KEN exists",1);


my $from_cache = Kynetx::Memcached::check_cache("KEN:default:$ck_old");
testit($from_cache,$ken,"Check memcache for cached copy of KEN");

# Check session for ken
$result = Kynetx::Persistence::KEN::get_ken($session);
testit($result,$ken,"Get KEN stored for session $ck_old",0);

## Check to see if this is KEN with a user account
# No good way to do this until we have authentication
#$result = Kynetx::Persistence::KEN::is_anonymous($session);
#testit($result,0,"KEN has a username from Accounts");

# Check automatic creation of new KENS

# needs a new session
my $sessionA = process_session($r);

# get an anonymous KEN for new session
my $kenA = Kynetx::Persistence::KEN::get_ken($sessionA);
testit($kenA,re($ken_re),"Anonymous KEN created for session",0);

# Check to see if this is KEN with an anonymous username
$result = Kynetx::Persistence::KEN::is_anonymous($sessionA);
testit($result,1,"KEN is anonymous");



sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    cmp_deeply($got,$expected,$description);
}

session_cleanup($session);

plan tests => $num_tests;
1;