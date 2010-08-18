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

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Modules::PDS::KEN qw/:all/;
my $logger = get_logger();
my $num_tests = 0;
my $result;

my $ck = "d528c1b5f7446c9322de70fbcaea1bb2";

# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();


my $r = new Kynetx::FakeReq();

my $new_session = process_session($r);
my $session = process_session($r,$ck);

# after this section we don't care about the session_id because we will be
# using the session object

my $ck_new= session_id($new_session); # store for later use
my $ck_old = session_id($session);

my $kenA;
my $kenB;

$logger->debug("Old Session Id: ",$ck_old);
$logger->debug("New Session Id: ",$ck_new);

# get the KEN
$kenA = Kynetx::Modules::PDS::KEN::get_ken($session);


$logger->debug("Found KEN: ", sub { Dumper($kenA)});

# get the KEN (return undef)
$kenB = Kynetx::Modules::PDS::KEN::get_ken($new_session);
cmp_deeply($kenB,undef,"KEN not found");

$kenB = Kynetx::Modules::PDS::KEN::new_ken();

$logger->debug("Found KEN: ", sub { Dumper($kenB)});

# get the PDS session
$result = Kynetx::Modules::PDS::get_pds_session($session,$kenA);

$logger->debug("Found this session: ", sub {Dumper($result)});

# get the PDS session
$result = Kynetx::Modules::PDS::get_pds_session($new_session,$kenB);

$logger->debug("Found this session: ", sub {Dumper($result)});

# get the KPDS for the session
$result = Kynetx::Modules::PDS::pds_get($session,$r);

ok(1);
plan tests => ++$num_tests;
1;