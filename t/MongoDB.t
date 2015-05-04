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
use Clone qw(clone);

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
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
my $base_save;

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

my $tricky_hash = {
	'a' => 1.1,
	'b' => [
		'c' => 2,
		'e' => 3,
		'f' => {
			'g' => 4, 
			'h' => [4, 6, 7]
		}
	],
};

my $hash_var = "aaBaa";
#Log::Log4perl->easy_init($DEBUG);

my $array_val = ['a','b','c','d','e','f','g',];
my $array_var = "abcd";

#goto ENDY;


$logger->debug("Save Array: ", sub {Dumper($array_val)});
$start = new Benchmark;
Kynetx::MongoDB::update_value($cruft,{'key' => $array_var},{'key' => $array_var, 'value' => $array_val},1);
$end = new Benchmark;
$base_save = timediff($end,$start);
diag "Save to Mongo: " . $base_save->[0];

$start = new Benchmark;
$result = Kynetx::MongoDB::get_array_element($cruft,$array_var,2);
$result = $result->{'value'};
$end = new Benchmark;
$base_save = timediff($end,$start);
diag "Element retrieval: " . $base_save->[0];
$logger->debug( "Fourth element: ", sub {Dumper($result)});

$start = new Benchmark;
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $array_var});
$result = $result->{'value'}->[2];
$end = new Benchmark;
$base_save = timediff($end,$start);
diag "Element retrieval: " . $base_save->[0];
$logger->debug( "Fourth element: ", sub {Dumper($result)});


#Kynetx::MongoDB::insert_hash($cruft,{'key' => $hash_var},$dummy_hash);
Kynetx::MongoDB::update_value($cruft,{'key' => $hash_var},{'key' => $hash_var, 'value' => $dummy_hash});
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $hash_var});

$logger->debug("R: ", sub {Dumper($result)});
compare($result->{'value'},$dummy_hash,"Hash save/get orthogonal",0);

# insert a new value
$expected = clone($dummy_hash);
my $nval =  "Stinky McStinkelton";
$expected->{'b'}->{'z'} = $nval;
Kynetx::MongoDB::put_hash_element($cruft,{'key' => $hash_var},['b','z'],{'key' => $hash_var, 'value' => $nval});
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $hash_var});
compare($result->{'value'},$expected,"Insert a new leaf",0);
$logger->debug("R: ", sub {Dumper($result)});

#replace a value with a sub-hash
my $sub_hash = {
	'fs0' => 'sub hash 0',
	'fs1' => 'sub hash 1',
	'fs2' => [1 , "13", 1.2, "apple"]
};
$expected->{'b'}->{'f'} = $sub_hash;
Kynetx::MongoDB::put_hash_element($cruft,{'key' => $hash_var},['b','f'],{'key' => $hash_var, 'value' =>$sub_hash});
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $hash_var});
compare($result->{'value'},$expected,"Insert a new branch",0);
$logger->debug("R: ", sub {Dumper($result)});


# change a value
$nval =  3.141569;
$expected->{'b'}->{'c'} = $nval;
Kynetx::MongoDB::put_hash_element($cruft,{'key' => $hash_var},['b','c'],{'key' => $hash_var, 'value' => $nval});
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $hash_var});
compare($result->{'value'},$expected,"Change a leaf",0);
$logger->debug("R: ", sub {Dumper($result)});

# change a value
delete $expected->{'b'}->{'f'}->{'fs0'};
Kynetx::MongoDB::delete_hash_element($cruft,{'key' => $hash_var},['b','f','fs0']);
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $hash_var});
compare($result->{'value'},$expected,"Delete a leaf",0);
$logger->debug("R: ", sub {Dumper($result)});

my $duplicate = 'aCCa';
Kynetx::MongoDB::put_hash_element($cruft,{'key' => $duplicate},[],{'key' => $duplicate, 'value' => $dummy_hash});
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $duplicate});
compare($result->{'value'},$dummy_hash,"Create a new hash",1);
$logger->debug("R: ", sub {Dumper($result)});

$result = Kynetx::MongoDB::get_hash_element($cruft,{'key' => $duplicate},['b','e'],{'key' => $duplicate, 'value' => $dummy_hash});
compare($result->{'value'},2.2,"Create a new hash",1);
$logger->debug("R: ", sub {Dumper($result)});

$result = Kynetx::MongoDB::get_hash_element($cruft,{'key' => $duplicate},[]);
compare($result->{'value'},$dummy_hash,"Create a new hash",1);

my $tricky = "bOb";
Kynetx::MongoDB::update_value($cruft,{'key' => $tricky},{'key' => $tricky, 'value' => $tricky_hash});
$result = Kynetx::MongoDB::get_value($cruft,{'key' => $tricky});
$logger->debug("R: ", sub {Dumper($result)});
compare($result->{'value'},$tricky_hash,"Hash within an array?",0);


delete_value($cruft,{'key' => $duplicate});
delete_value($cruft,{'key' => $hash_var});
delete_value($cruft,{'key' => $tricky});

# prepopulate dummy values for FIND_AND_MODIFY
my $find_and_modify;
my @keys = ();
foreach my $val ($who,$what,$where) {
	my $t = time();
	my $k = {
		"key" => $t
	};
	my $v = {
		"key" => $t,
		"value" => $val
	};
	Kynetx::MongoDB::update_value($cruft,$k,$v,1);
	push(@keys,$t);
	sleep 1;
}

my $description = "Find and remove";
my $first = pop(@keys);
$find_and_modify = {
	'query' => {'key' => $first},
	'remove' => 'true',
	#'new' => 'true'
};
$result = Kynetx::MongoDB::find_and_modify($cruft,$find_and_modify);
my $del = $result->{'value'};

$logger->debug("fnm: ", sub {Dumper($result)});
compare($del,$where,$description);

$description = "Find and Modify, return original value";
my $modify = "foosh";
my $second = pop(@keys);
$find_and_modify = {
	'query' => {'key' => $second},
	'update' => {'$set' => {'value' => $modify}},
};
$result = Kynetx::MongoDB::find_and_modify($cruft,$find_and_modify);
my $old = $result->{'value'};
$logger->debug("fnm: ", sub {Dumper($result)});
compare($old,$what,$description);

$description = "Find and Modify, touch";
my $now = time;
$find_and_modify = {
	'query' => {'key' => $second},
	'update' => {'$set' => {'modified' => $now}},
	'new' => 'true'
};
$result = Kynetx::MongoDB::find_and_modify($cruft,$find_and_modify);
$logger->debug("fnm: ", sub {Dumper($result)});
compare($result->{'value'},$modify,$description . " (same value)");
compare($result->{'modified'}, $now,$description . " (new modified)");

$description = "Insert new value with FNM";
$find_and_modify = {
	'query' => {'key' => $first - $second},
	'update' => {'$set' => {'value' => $del}},
	'new' => 'true',
	'upsert' => 'true'
};
$start = new Benchmark;
$result = Kynetx::MongoDB::find_and_modify($cruft,$find_and_modify);
$end = new Benchmark;
$base_save = timediff($end,$start);
#diag "Find and modify: " . $base_save->[0];

delete_value($cruft,{'key' => $first - $second});


$description = "Cleanup";
$find_and_modify = {
	'query' => {'key' => $second},
	'remove' => 'true',
	'new' => 'true',
};
$start = new Benchmark;
$result = Kynetx::MongoDB::find_and_modify($cruft,$find_and_modify);
$end = new Benchmark;
$base_save = timediff($end,$start);
diag "Find and modify (delete): " . $base_save->[0];
$logger->debug("fnm: ", sub {Dumper($result)});



my $third = pop(@keys);
$start = new Benchmark;
delete_value($cruft,{'key' => $third});
$end = new Benchmark;
$base_save = timediff($end,$start);
diag "Regular Delete: " . $base_save->[0];

$logger->debug("fnm: ", sub {Dumper($result)});
$start = new Benchmark;
Kynetx::MongoDB::update_value($cruft,$key,$value,1);
$end = new Benchmark;
$base_save = timediff($end,$start);
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
#$expected = "edata$fken$who$frid";
#
#compare($got,$expected,"Entity cache key");

Kynetx::Persistence::Entity::put_edatum($frid,$fken,$who,$where);

$expected = undef;
$got = Kynetx::MongoDB::get_cache("edata",$key);
compare($got,$expected,"Not in memcache yet");

#Log::Log4perl->easy_init($DEBUG);


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


$key->{"key"} = $where;
touch_value($cruft,$key);
$result = get_value($cruft,$key);
compare($result->{"value"},0,"Initalize a $where to 0 (touch)",1);

delete_value($cruft,$key);



ENDY:

my $num_vals = 5;
$key = $DICTIONARY[rand(@DICTIONARY)];
chomp($key);
my @list = ();
my $upper_limit = 100;
my $min = $upper_limit;
my $max = 0;
my $sum = 0;
my $collection = Kynetx::MongoDB::get_collection($cruft);
for (my $i=0;$i<$num_vals;$i++ ) {
  my $rnd = int (rand($upper_limit));
  push (@list,$rnd);
  if ($rnd > $max) {
    $max = $rnd;
  }
  if ($rnd < $min) {
    $min = $rnd;
  }
  $sum += $rnd;
  $collection->save({'key' => $key, 'value' => $rnd});  
}
$description = "Test mongoDB pipeline operators";
my $match = {'key' => $key};
my $group = {'_id' => $key, 
    'max' => {'$max' => '$value'},
  'min' => {'$min' => '$value'},
  'sum' => {'$sum' => '$value'}
};
$result = Kynetx::MongoDB::aggregate_group($cruft,$match,$group);
cmp_deeply($result->[0]->{'max'}, $max,$description. " (max)");
$num_tests++;
cmp_deeply($result->[0]->{'min'}, $min,$description. " (min)");
$num_tests++;
cmp_deeply($result->[0]->{'sum'}, $sum,$description. " (sum)");
$num_tests++;

delete_value($cruft,$match);

sub compare {
    my ($got,$expected,$description,$diag) =@_;
    if ($diag) {
        $logger->debug("Test: $description: ", sub {Dumper($got)});
    }
    my $r = cmp_deeply($got,$expected,$description);
    $num_tests++;
    die unless ($r);
}



plan tests => $num_tests;

1;


