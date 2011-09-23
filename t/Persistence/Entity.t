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
use Apache::Session::Memcached;
use DateTime;
use Benchmark ':hireswallclock';

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
#use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::Entity qw/:all/;
my $logger = get_logger();
my $num_tests = 0;
my $result;
my $expected;

# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $r = new Kynetx::FakeReq();
my $oid_re = qr([0-9|a-f]{16});


my $ken = "4c6484f5a1a31171365896f4";
my $cleanup = 1;

# Rule stuff
my $fkan = 93402939302;
my $k1024 = "4c7d71a167458b950b000000";
my $ka144 = "4c61e016ab900dc2f8aab2ce";
my $rnd1 = int(rand(200));
my $rnd2 = int(rand(100));
my $rid1 = "1024";
my $rid2 = "a144x22";
my $ridR = "test".$rnd1."x".$rnd2;
my $skey = "buildarray";
my ($start,$end);


# get random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $key1 = $DICTIONARY[rand(@DICTIONARY)];
my $key2 = $DICTIONARY[rand(@DICTIONARY)];
my $key3 = $DICTIONARY[rand(@DICTIONARY)];
chomp($key1);
chomp($key2);
chomp($key3);

# basic Entity getter/setter
$start = new Benchmark;
$result = Kynetx::Persistence::Entity::put_edatum($rid1,$ken,$skey,$key2);
$end = new Benchmark;
if (ref $result eq "HASH") {
	$result = $result->{"ok"};
}
my $qtime = timediff($end,$start);
#diag "Save to Mongo: " . $qtime->[0];
$logger->debug("Result: ", sub {Dumper($result)});
testit($result,1,"Insert data for $rid1/$ken",0);

$start = new Benchmark;
$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$skey);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "Get from Mongo: " . $qtime->[0];
testit($result,$key2,"Retrieve data for $rid1/$ken/$key1",0);

$start = new Benchmark;
Kynetx::Persistence::Entity::push_edatum($rid1,$ken,$skey,$key3);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "Convert primitive to array: " . $qtime->[0];

$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$skey);
$expected = [$key2,$key3];
testit($result,$expected,"Convert primitive to array",0);
$logger->debug("Result: ", sub {Dumper($result)});

$start = new Benchmark;
Kynetx::Persistence::Entity::push_edatum($rid1,$ken,$skey,$key1);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "Push on array: " . $qtime->[0];
$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$skey);
$expected = [$key2,$key3,$key1];
testit($result,$expected,"Add value to existing array",0);
$logger->debug("Result: ", sub {Dumper($result)});

$start = new Benchmark;
$result = Kynetx::Persistence::Entity::pop_edatum($rid1,$ken,$skey);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "Pop from array: " . $qtime->[0];
$expected = $key1;
testit($result,$expected,"Pop value from array",0);

$result = Kynetx::Persistence::Entity::pop_edatum($rid1,$ken,$skey,1);
$expected = $key2;
testit($result,$expected,"shift value from array",0);

Kynetx::Persistence::Entity::delete_edatum($rid1,$ken,$skey);

#Hash insert
my $dummy_hash = {
	'a' => '1.1',
	'b' => {
		'c' => '2.1',
		'e' => '2.2',
		'f' => {
			'g' => ['3.a','3.b','3.c','3.d'],
			'h' => 5
		}
	},
	'd' =>'1.3'	
};
#Log::Log4perl->easy_init($TRACE);

my $hash_varname = "aaBaa";
$start = new Benchmark;
$result = Kynetx::Persistence::Entity::put_edatum($rid1,$ken,$hash_varname,$dummy_hash);
$logger->info("Result: ", sub {Dumper($result)});
$end = new Benchmark;
#if (ref $result eq "HASH") {
#	$result = $result->{"ok"};
#}


$qtime = timediff($end,$start);
diag "Save to Mongo: " . $qtime->[0];
$logger->info("Result: ", sub {Dumper($result)});
testit($result,6,"Insert hash data for $rid1/$ken",1);

$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$hash_varname);
testit($result,$dummy_hash,"Reconstituted hash",0);

my $path = ['d'];
$result = Kynetx::Persistence::Entity::get_hash_edatum($rid1,$ken, $hash_varname,$path);
testit($result,1.3,"Get a single hash element");

Kynetx::Persistence::Entity::put_hash_edatum($rid1,$ken,$hash_varname,$path,"Fiddlesticks");
$result = Kynetx::Persistence::Entity::get_hash_edatum($rid1,$ken, $hash_varname,$path);
testit($result,"Fiddlesticks","Get a single hash element");
$logger->debug("Result: ", sub {Dumper($result)});

my $subhash = {
	'pi' => 3.14156,
	'opts' => ['yes', 'no']
};

Kynetx::Persistence::Entity::put_hash_edatum($rid1,$ken,$hash_varname,$path,$subhash);
$result = Kynetx::Persistence::Entity::get_hash_edatum($rid1,$ken, $hash_varname,$path);
testit($result,$subhash,"Get a single hash element--which happens to be a hash");
$logger->debug("Result: ", sub {Dumper($result)});

Kynetx::Persistence::Entity::delete_hash_edatum($rid1,$ken,$hash_varname,$path);
$result = Kynetx::Persistence::Entity::get_hash_edatum($rid1,$ken, $hash_varname,$path);
testit($result,undef,"delete a hash element");
$logger->debug("Result: ", sub {Dumper($result)});


Kynetx::Persistence::Entity::delete_edatum($rid1,$ken,$hash_varname);
$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$hash_varname);
testit($result,undef,"Deleted all hash ref",0);


# stack operations as trail

my $trail_element = [$rnd1,DateTime->now->epoch];

$result = Kynetx::Persistence::Entity::put_edatum($rid1,$ken,$skey,$key2);
Kynetx::Persistence::Entity::push_edatum($rid1,$ken,$skey,$trail_element,1);

$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$skey);
$expected = [
    [$key2,re(qr(\d+))],
    $trail_element,
];
testit($result,$expected,"Create new trail",0);

my $third_trail_var = [$key3,DateTime->now->epoch];
Kynetx::Persistence::Entity::push_edatum($rid1,$ken,$skey,$third_trail_var,1);
$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$skey);
$expected = [
    [$key2,re(qr(\d+))],
    $trail_element,
    $third_trail_var
];
testit($result,$expected,"Add to existing trail",0);

$result = Kynetx::Persistence::Entity::pop_edatum($rid1,$ken,$skey);
$expected = $third_trail_var;
testit($result,$expected,"Pop value from trail",0);


$result = Kynetx::Persistence::Entity::pop_edatum($rid1,$ken,$skey,1);
$expected = [$key2,re(qr(\d+))];
testit($result,$expected,"Pop value from trail",0);

$result = Kynetx::Persistence::Entity::get_edatum($rid1,$ken,$skey);
$expected = [$trail_element];
testit($result,$expected,"Check trail remainder",0);



# Store to a new ruleset
$start = new Benchmark;
$result = Kynetx::Persistence::Entity::put_edatum($ridR,$ken,$key1,$key3);
$end = new Benchmark;
if (ref $result eq "HASH") {
	$result = $result->{"ok"};
}
$qtime = timediff($end,$start);
#diag "Save to Mongo: " . $qtime->[0];
testit($result,1,"Insert to new store $ridR",0);

$result = Kynetx::Persistence::Entity::get_edatum($ridR,$ken,$key1);
testit($result,$key3,"Retrieve data for $ridR/$ken/$key1",0);


$result = Kynetx::Persistence::Entity::touch_edatum($ridR,$ken,$key3);
testit($result,0,"Touch a variable");

if ($cleanup) {
    Kynetx::Persistence::Entity::delete_edatum($rid1,$ken,$skey);
    Kynetx::Persistence::Entity::delete_edatum($ridR,$ken,$key1);
    Kynetx::Persistence::Entity::delete_edatum($ridR,$ken,$key3);
}

sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    my $r = cmp_deeply($got,$expected,$description);
    die unless ($r);
}

plan tests => $num_tests;
1;