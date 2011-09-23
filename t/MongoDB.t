#!/usr/bin/perl -w
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
#Log::Log4perl->easy_init($TRACE);

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
my $yav = $DICTIONARY[rand(@DICTIONARY)];
chomp($what);
chomp($where);
chomp($who);
chomp($yav);

$logger->debug("Who:   $who");
$logger->debug("What:  $what");
$logger->debug("Where: $where");

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
my $start;
my $end;

# Check Database
@result = $mdb->collection_names();
$expected = superbagof($dictionary,'edata','appdata','kens','tokens');
compare(\@result,$expected,"Has expected collections",0);

# save a value
$key = {
    "key" => "buildtrail"
};

$value = {
    "key" => "buildtrail",
    "value" => $what
};
my $value1 = {
    "key" => "buildtrail",
    "value" => $who
};
my $value2 = {
    "key" => "buildtrail",
    "value" => $where
};

$start = new Benchmark;
Kynetx::MongoDB::update_value($cruft,$key,$value,1);
$end = new Benchmark;
my $base_save = timediff($end,$start);
#diag "Save to Mongo: " . $base_save->[0];

$start = new Benchmark;
Kynetx::MongoDB::push_value($cruft,$key,$value2);
$end = new Benchmark;
my $stack_query = timediff($end,$start);
#diag "Convert to stack: ". $stack_query->[0];

$result = Kynetx::MongoDB::get_value($cruft,$key);
$got = $result->{"value"};
$expected = [$value->{"value"},$value2->{"value"}];
compare($got,$expected,"Convert a primary var to a trail");

$start = new Benchmark;
Kynetx::MongoDB::push_value($cruft,$key,$value1);
$end = new Benchmark;
$stack_query = timediff($end,$start);
#diag "Push on existing stack: ". $stack_query->[0];
$result = Kynetx::MongoDB::get_value($cruft,$key);
$got = $result->{"value"};
$expected = [$value->{"value"},$value2->{"value"},$value1->{"value"}];
compare($got,$expected,"Push var on a array");

$start = new Benchmark;
$result = Kynetx::MongoDB::pop_value($cruft,$key);
$end = new Benchmark;
$stack_query = timediff($end,$start);
#diag "Stack pop: ". $stack_query->[0];
$got = $result;
$expected = $value1->{"value"};
compare($got,$expected,"Pop value from array returns " . $value1->{"value"});


$start = new Benchmark;
$result = Kynetx::MongoDB::pop_value($cruft,{"key" => "foop"});
$end = new Benchmark;
$stack_query = timediff($end,$start);
#diag "Stack pop: ". $stack_query->[0];
$got = $result;
$expected = undef;
compare($got,$expected,"Pop value from null array returns " . $expected);

$result = Kynetx::MongoDB::pop_value($cruft,$key,1);
$got = $result;
$expected = $value->{"value"};
compare($got,$expected,"Shift value from array returns " . $value->{"value"});

$result = Kynetx::MongoDB::pop_value($cruft,$key);
$got = $result;
$expected = $value2->{"value"};
compare($got,$expected,"Pop last value from array returns " . $value2->{"value"});

$result = Kynetx::MongoDB::pop_value($cruft,$key);
$got = $result;
$expected = undef;
compare($got,$expected,"Pop value from empty array returns null");

Kynetx::MongoDB::push_value($cruft,$key,$value2);
$result = Kynetx::MongoDB::get_value($cruft,$key);
$got = $result->{"value"};
$expected = [$value2->{"value"}];
compare($got,$expected,"Add element to empty array");

delete_value($cruft,$key);

Kynetx::MongoDB::push_value($cruft,$key,$value1);
$result = Kynetx::MongoDB::get_value($cruft,$key);
$got = $result->{"value"};
$expected = [$value1->{"value"}];
compare($got,$expected,"Start a new trail");

Kynetx::MongoDB::update_value($cruft,$key,$value,1);
$result = Kynetx::MongoDB::pop_value($cruft,$key);
$got = $result;
$expected = $value->{"value"};
compare($got,$expected,"Pop value from array returns " . $value->{"value"});

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

$start = new Benchmark;
$result = Kynetx::MongoDB::get_value("edata",$key);
$got = $result->{"value"};
$end = new Benchmark;
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
#diag "Mongo query: ". $m_query->[0];
#diag "Cache query: ". $c_query->[0];

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
#diag "Mongo query: ". $m_query->[0];

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

#diag "Stop master server now";
#sleep 5;

$result = touch_value($cruft,$key);
my $touch2 = $result->{"created"};

cmp_ok($touch2,'>=',$touch1,"Touch the creation time");
$num_tests++;
my $three_days_ago = DateTime->now->add( days => -3 );
$result = touch_value($cruft,$key,$three_days_ago);

my $touch3 = $result->{"created"};
cmp_ok($touch3,'<',$touch1,"Set the creation time (-3 days)");
$num_tests++;

$result = atomic_set($cruft,$key,'value',$yav);
compare($result,1,"atomic set",1);

$result = get_value($cruft,$key);
compare($result->{"value"},$yav,"Check for atomic update",1);

delete_value($cruft,$key);

$key->{"key"} = $where;
touch_value($cruft,$key);
$result = get_value($cruft,$key);
compare($result->{"value"},0,"Initalize a $where to 0 (touch)",1);

delete_value($cruft,$key);



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


