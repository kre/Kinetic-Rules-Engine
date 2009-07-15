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
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Apache::Session::Memcached;
use DateTime;

use Kynetx::Test qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Util qw/:all/;


# configure KNS
Kynetx::Configure::configure();

my $logger = get_logger();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

my $r = new Kynetx::FakeReq();

my $session = process_session($r);

my $rid = 'rid123';

plan tests => 29;

session_store($rid, $session, 'a', 3);

is(session_get($rid, $session, 'a'), 3, 'storing a simple value');

my $now = DateTime->now->epoch;
ok(session_created($rid, $session, 'a') <= $now, 'var created in the past');

ok(session_defined($rid, $session, 'a'), 'the variable is defined');

session_delete($rid, $session, 'a');

ok(!session_defined($rid, $session, 'a'), 'the variable is not defined');

is(session_get($rid, $session, 'a'), undef, 'do values get deleted?');
is(session_created($rid, $session, 'a'), undef, 'deleting a var deletes timestamp too');

my $hash = {'x' => 4, 'y' => 'a string'};
session_store($rid, $session, 'b', $hash);

is(session_get($rid, $session, 'b'), $hash, 'storing a hash');

ok(session_within($rid, $session, 'b', 5, 'seconds'), 'b stored within last 5 seconds');

ok(session_within($rid, $session, 'b', 3, 'minutes'), 'b stored within last 3 minutes');

ok(session_within($rid, $session, 'b', 3, 'hours'), 'b stored within last 3 hours');

ok(session_within($rid, $session, 'b', 3, 'days'), 'b stored within last 3 days');

ok(session_within($rid, $session, 'b', 3, 'weeks'), 'b stored within last 3 week');

ok(session_within($rid, $session, 'b', 3, 'months'), 'b stored within last 3 months');

sleep 2; # sleep to make sure one second has passed

ok(!session_within($rid, $session, 'b', 1, 'seconds'), 'b not stored within last 1 seconds');


session_delete($rid, $session, 'b');

session_inc_by_from($rid, $session, 'b', 4, 1);
is(session_get($rid, $session, 'b'), 1, 'initialization of b');

session_inc_by_from($rid, $session, 'b', 4, 1);
is(session_get($rid, $session, 'b'), 5, 'incrementing b');

session_inc_by_from($rid, $session, 'b', 4, 1);
is(session_get($rid, $session, 'b'), 9, 'incrementing b again');

session_inc_by_from($rid, $session, 'b', -10, 1);
is(session_get($rid, $session, 'b'), -1, 'decrementing b');

session_delete($rid, $session, 'b');

session_delete($rid, $session, 'c');
ok(!session_true($rid, $session, 'c'), "undefined isn't true");

session_clear($rid, $session, 'c');
ok(!session_true($rid, $session, 'c'), "clearing undef is still false");

session_set($rid, $session, 'c');
ok(session_true($rid, $session, 'c'), "set makes it true");

session_clear($rid, $session, 'c');
ok(!session_true($rid, $session, 'c'), "clear makes it false");

session_delete($rid, $session, 'b');

##
## Check namespacing for independence of RIDs
##

my $rid1 = 'rid456';

session_delete($rid, $session, 'a');
session_delete($rid1, $session, 'a');

session_store($rid, $session, 'a', 3);
session_store($rid1, $session, 'a', 4);

is(session_get($rid, $session, 'a'), 3, 'storing a simple value for rid');
is(session_get($rid1, $session, 'a'), 4, 'storing a simple value for rid1');


session_inc_by_from($rid, $session, 'a', 4, 1);
is(session_get($rid, $session, 'a'), 7, 'incrementing a for rid');

session_inc_by_from($rid1, $session, 'a', 4, 1);
is(session_get($rid1, $session, 'a'), 8, 'incrementing a for rid1');

session_delete($rid, $session, 'a');

ok(!session_defined($rid, $session, 'a'), 'the variable is not defined for rid');
ok(session_defined($rid1, $session, 'a'), 'the variable is still defined for rid1');


session_delete($rid1, $session, 'a');

ok(!session_defined($rid1, $session, 'a'), 'the variable is not defined for rid1');


1;


