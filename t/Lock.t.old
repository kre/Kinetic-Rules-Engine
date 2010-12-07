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
use Apache::Session::Lock::File;
use DateTime;
use APR::URI;
use APR::Pool ();
use Benchmark ':hireswallclock';

use Kynetx::Test qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Util qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


# configure KNS
Kynetx::Configure::configure();

my $logger = get_logger();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

my $r = new Kynetx::FakeReq();

my $session = process_session($r);

my $ck= session_id($session); # store for later use
my $lockid = "lock-".$ck;

diag "Session id is: ",$ck;

my $rid = 'rid123';
my $rid2 = "cs_test";

my $my_req_info = Kynetx::Test::gen_req_info($rid, {'domain' => 'web'});
my $other_req_info = Kynetx::Test::gen_req_info($rid2, {'domain' => 'web'});
my $result;
my $patience = Kynetx::Configure::get_config("LOCK_PATIENCE");

diag "Lock timeout set to $patience seconds";

my $start = new Benchmark;
if ($my_req_info->{"_lock"}->lock($lockid)) {
    $result = 1;
} else {
    $result = 0;
}

ok($result,"First lock requested");

#diag("Request a lock for locked object");
if ($my_req_info->{"_lock"}->lock($lockid)) {
    $result = 1;
} else {
    $result =0;
}
ok(! $result,"Lock request fails on locked object");
my $lid = Kynetx::Memcached::check_cache($lockid);

ok($lid,"Lock exists in Memcache");

my $end = new Benchmark;
my $rp_diff = timediff($end,$start);

cmp_ok($rp_diff,'>=',$patience,"Times out after $patience");

#diag "Request lock for $rid2";
$result = $other_req_info->{"_lock"}->lock($lockid);
ok(!$result,"Lock request denied for alternate RID");

#diag("Release the first lock");
$my_req_info->{"_lock"}->unlock;


$result = $other_req_info->{"_lock"}->lock($lockid);
ok($result,"Lock has been released");

$my_req_info->{'_lock'}->unlock;
$lid = Kynetx::Memcached::check_cache($lockid);
ok(!$lid,"Lock erased from Memcache");

session_cleanup($session);
done_testing();
1;


