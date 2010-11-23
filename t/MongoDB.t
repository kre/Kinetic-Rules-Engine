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
use Cache::Memcached;
use Benchmark ':hireswallclock';

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached;

my $logger = get_logger();
my $num_tests = 0;

############
# Expected values
my $result;
my @result;
my $expected;
my $dictionary = 'dictionary';
my $global_iname = 'kynetx';
my $frid = "test64x192";
my $fken = "4ce175b9ba381431de46e6d7";

#my $collections = ($dictionary,'edata','appdata','kens','tokens');
my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $what = $DICTIONARY[rand(@DICTIONARY)];
my $who = $DICTIONARY[rand(@DICTIONARY)];
my $where = $DICTIONARY[rand(@DICTIONARY)];
chomp($what);
chomp($where);
chomp($who);


Kynetx::Configure::configure();

Kynetx::MongoDB::init();

Kynetx::Memcached->init();

# Basic MongoDB commands
my $mdb = Kynetx::MongoDB::get_mongo();
my $var;
my $val;
my $kxri;
my $key;
my $got;
my $value;
my $cruft = "cruft";

# Check Database
@result = $mdb->collection_names();
$expected = superbagof($dictionary,'edata','appdata','kens','tokens');
compare(\@result,$expected,"Has expected collections",0);

# build an entity keystring
$key = {
    "ken" => $fken,
    "rid" => $frid,
    "key" => $who
};

$value = {
    "key" => $who,
    "value" => $where
};

$got = Kynetx::MongoDB::make_keystring("edata",$key);
$expected = "edata$fken$who$frid";

compare($got,$expected,"Entity cache key");

Kynetx::Persistence::Entity::put_edatum($frid,$fken,$who,$where);

$expected = undef;
$got = Kynetx::MongoDB::get_cache("edata",$key);
compare($got,$expected,"Not in memcache yet");

my $start = new Benchmark;
$result = Kynetx::MongoDB::get_value("edata",$key);
$got = $result->{"value"};
my $end = new Benchmark;
my $m_query = timediff($end,$start);

compare($got,$where,"Value saved to Mongo");

$got = Kynetx::MongoDB::get_cache("edata",$key);
compare($got,$result,"Value saved to memcached");

$start = new Benchmark;
$result = Kynetx::MongoDB::get_value("edata",$key);
$got = $result->{"value"};
$end = new Benchmark;
my $c_query = timediff($end,$start);
compare($got,$where,"Value returned from memcached");
diag "Mongo query: ". $m_query->[0];
diag "Cache query: ". $c_query->[0];

Kynetx::Persistence::Entity::put_edatum($frid,$fken,$who,$what);

$expected = undef;
$got = Kynetx::MongoDB::get_cache("edata",$key);
compare($got,$expected,"Update deletes value in memcache");

$start = new Benchmark;
$result = Kynetx::MongoDB::get_value("edata",$key);
$got = $result->{"value"};
$end = new Benchmark;
$m_query = timediff($end,$start);
compare($got,$what,"Value returned from Mongo get after (eventually consistent) update");
diag "Mongo query: ". $m_query->[0];

Kynetx::Persistence::Entity::delete_edatum($frid,$fken,$who);
$expected = undef;
$got = Kynetx::MongoDB::get_cache("edata",$key);
compare($got,$expected,"Delete deletes value in memcache");

# Check Collection
my $coll = $mdb->get_collection($dictionary);
$kxri = $coll->find_one({'name' => $global_iname});
$expected = superhashof( {
    "_id" => ignore(),
    "name" => $global_iname
});
compare($kxri,$expected,"Kynetx inum",0);

# save a value
$key = {
    "key" => $who
};

$value = {
    "key" => $who,
    "value" => $what
};

$result = Kynetx::MongoDB::update_value($cruft,$key,$value,1);

$result = get_value($cruft,$key);
my $touch1 = $result->{"created"};
$got = $result->{"value"};

compare($got,$what,"Get the saved value",0);

sleep 1;

$result = touch_value($cruft,$key);
my $touch2 = $result->{"created"};

cmp_ok($touch2,'>',$touch1,"Touch the creation time");
$num_tests++;
my $three_days_ago = DateTime->now->add( days => -3 );
$result = touch_value($cruft,$key,$three_days_ago);

my $touch3 = $result->{"created"};
cmp_ok($touch3,'<',$touch1,"Set the creation time (-3 days)");
$num_tests++;

delete_value($cruft,$key);

$key->{"key"} = $where;
touch_value($cruft,$key);
$result = get_value($cruft,$key);
compare($result->{"value"},0,"Initalize a $where to 0 (touch)",0);

delete_value($cruft,$key);

# get_value
$var = {'name' => $global_iname};
$result = get_value($dictionary,$var);
compare($result,$kxri,"Get Value",0);




sub compare {
    my ($got,$expected,$description,$diag) =@_;
    if ($diag) {
        $logger->debug("Test: $description: ", sub {Dumper($got)});
    }
    cmp_deeply($got,$expected,$description);
    $num_tests++;
}

plan tests => $num_tests;

1;


