#!/usr/bin/perl -w

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use Clone qw(clone);


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

use Kynetx::Test qw/:all/;
use Kynetx::Postlude qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Persistence qw/:all/;
use Kynetx::Persistence::KEN qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached;
use Kynetx::MongoDB;
use Benchmark ':hireswallclock';

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();


Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $kobj_root = Kynetx::Configure::get_config('KOBJ_ROOT');
$logger->debug("KOBJ root: $kobj_root");

my $test_count = 0;
my $stack_size = 5;
my $start;
my $end;
my $qtime;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

#my $session = Kynetx::Test::gen_session($r, $rid);
my $session = Kynetx::Session::process_session($r);
$logger->trace("Initial session:",sub {Dumper($session)});
#Kynetx::Test::gen_app_session($r, $my_req_info);

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

my ($got, $expected, $description);
my ($domain,$var,$val,$from);
my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
$logger->trace("New ken session:",sub {Dumper($session)});
my $key = {
    "ken" => $ken,
    "rid" => $rid,
};
$logger->trace("What:  $what");
$logger->trace("Who:   $who");
$logger->trace("Where: $where");

goto ENDY;

######### The way this works, you could loop these tests over
######### Entity and Application variables, but I'm keeping them linear for now

########## Entity Variables
#Log::Log4perl->easy_init($DEBUG);
diag "There are some tolerances involved with some of the trail timing issues";
diag "Run the test stand-alone if an error occurs with one of the *Check* tests ";
#diag "Start with Entity Variables";
$domain = 'ent';

#Kynetx::MongoDB::get_value("edata",{"key" => "feebleenull"});
$var = "evar";
$val = $who;
$description = "Set a value ($val)";
$key->{"key"} = $var;
$start = new Benchmark;
$got = save_persistent_var($domain,$rid,$session,$var,$val);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "First save: " . $qtime->[0];
cmp_deeply($got,$val,$description);
$test_count++;
$logger->debug("Post save session:",sub {Dumper($session)});

$description = "Check $var for $val";
my $result = Kynetx::MongoDB::get_value("edata",$key);
$logger->debug("$description: ",sub {Dumper($result)});
$got = $result->{"value"};
cmp_deeply($got,$val,$description);
$test_count++;

$description = "Retrieve value from ($var)";
$start = new Benchmark;
$got = get_persistent_var($domain,$rid,$session,$var);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: " . $qtime->[0];
cmp_deeply($got,$val,$description);
$test_count++;

$description = "Retrieve creation time from ($var)";
$got = get_persistent_var($domain,$rid,$session,$var,1);
cmp_deeply($got,re(qr/[0..9]+/),$description);
$test_count++;

$description = "Delete value ($var) from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

$description = "Add a new counter";
$var = $what;
my $num = 3;
my $incr = -1;
$got = increment_persistent_var($domain,$rid,$session,$var,$incr,$num);
cmp_deeply($got,$num,$description);
$test_count++;

$description = "Increment existing counter";
$var = $what;
$num = 3;
$incr = -1;
$got = increment_persistent_var($domain,$rid,$session,$var,$incr,$num);
cmp_deeply($got,$num + $incr,$description);
$test_count++;

$description = "Convert value to trail";
$var = $what;
$val = $where;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$num + $incr, re(qr/\d+/)]);
$start = new Benchmark;
add_trail_element($domain,$rid,$session,$var,$val);
$got = get_persistent_var($domain,$rid,$session,$var);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,$expected,$description);
$test_count++;


$description = "Delete value ($var) from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

$description = "Start a new trail";
$var = "this_trail";
$val = $where;
$expected = bag([$where, re(qr/\d+/)]);
$start = new Benchmark;
add_trail_element($domain,$rid,$session,$var,$val);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,$expected,$description);
$test_count++;

sleep 1;

$description = "Add to a trail";
$var = "this_trail";
$val = $who;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$who, re(qr/\d+/)],
);
$start = new Benchmark;
add_trail_element($domain,$rid,$session,$var,$val);
$got = get_persistent_var($domain,$rid,$session,$var);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,$expected,$description);
$test_count++;

sleep 1;

$description = "Add another to a trail";
$var = "this_trail";
$val = $what;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$who, re(qr/\d+/)],
    [$what, re(qr/\d+/)],
);
$start = new Benchmark;
add_trail_element($domain,$rid,$session,$var,$val);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,$expected,$description);
$test_count++;


$description = "Check for element in trail";
$var = "this_trail";
$val = $who;
$start = new Benchmark;
$got = contains_trail_element($domain,$rid,$session,$var,$val);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply(1,num($got),$description);
$test_count++;

$description = "Check for $who before $what in trail";
$var = "this_trail";
$val = $who;
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$start = new Benchmark;
$got = trail_element_before($domain,$rid,$session,$var,$who,$what);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply(1,$got,$description);
$test_count++;



my $timevalue = 2;
my $timeframe = "seconds";
$val = $who;
$description = "Check for $val within $timevalue $timeframe";
$var = "this_trail";
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$start = new Benchmark;
$got = trail_element_within($domain,$rid,$session,$var,$val,$timevalue,$timeframe);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,1,$description);
$test_count++;

sleep 1;

$val = $where;
$description = "Check for $val within $timevalue $timeframe";
$var = "this_trail";
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$start = new Benchmark;
$got = trail_element_within($domain,$rid,$session,$var,$val,$timevalue,$timeframe);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,0,$description);
$test_count++;


$description = "Remove element from a trail";
$var = "this_trail";
$val = $who;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$what, re(qr/\d+/)],
);
$start = new Benchmark;
$got = delete_trail_element($domain,$rid,$session,$var,$val);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,$expected,$description);
$test_count++;


$description = "Delete value ($var) from mongo";
$start = new Benchmark;
delete_persistent_var($domain,$rid,$session,$var);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

$var = $who;
$description = "Touch a variable ($var)";
$start = new Benchmark;
$got = touch_persistent_var($domain,$rid,$session,$var);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,0,$description);
$test_count++;

$description = "Delete value ($var) from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

#Log::Log4perl->easy_init($DEBUG);
$var = "stack";
for my $i (0 .. $stack_size) {
    $logger->debug($i);
    my $struct = {
        "index" => $i,
        $i => $who
    };
    add_trail_element($domain,$rid,$session,$var,$struct);
}

$description = "Shift a value off the stack";
$expected = {
    "index" => 0,
    0 => $who
};
$start = new Benchmark;
$got = consume_trail_element($domain,$rid,$session,$var,1);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,$expected,$description);
$test_count++;


$description = "Pop a value off the stack";
$expected = {
    "index" => $stack_size,
    $stack_size => $who
};
$start = new Benchmark;
$got = consume_trail_element($domain,$rid,$session,$var,0);
cmp_deeply($got,$expected,$description);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
$test_count++;

$description = "Pop a value off the stack";
$expected = {
    "index" => $stack_size-1,
    $stack_size-1 => $who
};
$got = consume_trail_element($domain,$rid,$session,$var,0);
cmp_deeply($got,$expected,$description);
$test_count++;

$description = "Delete value ($var) from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

##################################################  Application Variables
#Log::Log4perl->easy_init($DEBUG);
#diag "Continue with Application Variables";
$domain = 'app';

$var = "appvar";
$val = $who;
$description = "Set a value ($val)";
$got = save_persistent_var($domain,$rid,$session,$var,$val);
cmp_deeply($got,$val,$description);
$test_count++;

my $nkey;
$nkey->{"key"} = $var;
$nkey->{"rid"} = $rid;
$description = "Check $var for $val";
$got = Kynetx::MongoDB::get_value("appdata",$nkey)->{"value"};
cmp_deeply($got,$val,$description);
$test_count++;

$description = "Retrieve value from ($var)";
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,$val,$description);
$test_count++;

$description = "Retrieve creation time from ($var)";
$got = get_persistent_var($domain,$rid,$session,$var,1);
cmp_deeply($got,re(qr/[0..9]+/),$description);
$test_count++;

$description = "Delete value from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

$description = "Check value for deletion";
$got = get_persistent_var($domain,$rid,$session,$var,1);
cmp_deeply($got,undef,$description);
$test_count++;

$description = "Add a new counter";
$var = $what;
$num = 3;
$incr = -1;
$got = increment_persistent_var($domain,$rid,$session,$var,$incr,$num);
cmp_deeply($got,$num,$description);
$test_count++;

$description = "Increment existing counter";
$var = $what;
$num = 3;
$incr = -1;
$got = increment_persistent_var($domain,$rid,$session,$var,$incr,$num);
cmp_deeply($got,$num + $incr,$description);
$test_count++;

$description = "Convert value to trail";
$var = $what;
$val = $where;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$num + $incr, re(qr/\d+/)]);
add_trail_element($domain,$rid,$session,$var,$val);
$start = new Benchmark;
$got = get_persistent_var($domain,$rid,$session,$var);
$end = new Benchmark;
$qtime = timediff($end,$start);
#diag "$description: ". $qtime->[0];
cmp_deeply($got,$expected,$description);
$test_count++;

$description = "Delete value from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

$description = "Start a new trail";
$var = "this_trail";
$val = $where;
$expected = bag([$where, re(qr/\d+/)]);
add_trail_element($domain,$rid,$session,$var,$val);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,$expected,$description);
$test_count++;

sleep 1;


$description = "Add to a trail";
$var = "this_trail";
$val = $who;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$who, re(qr/\d+/)],
);
add_trail_element($domain,$rid,$session,$var,$val);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,$expected,$description);
$test_count++;

sleep 1;

$description = "Add another to a trail";
$var = "this_trail";
$val = $what;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$who, re(qr/\d+/)],
    [$what, re(qr/\d+/)],
);
add_trail_element($domain,$rid,$session,$var,$val);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,$expected,$description);
$test_count++;

#diag Dumper($got);

$description = "Check for element in trail";
$var = "this_trail";
$val = $who;
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$got = contains_trail_element($domain,$rid,$session,$var,$val);
cmp_deeply(1,num($got),$description);
$test_count++;

$description = "Check for $who before $what in trail";
$var = "this_trail";
$val = $who;
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$got = trail_element_before($domain,$rid,$session,$var,$who,$what);
cmp_deeply(1,$got,$description);
$test_count++;

$timevalue = 2;
$timeframe = "seconds";
$val = $who;
$description = "Check for $val within $timevalue $timeframe";
$var = "this_trail";
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$got = trail_element_within($domain,$rid,$session,$var,$val,$timevalue,$timeframe);
cmp_deeply($got,1,$description);
$test_count++;

sleep 1;
$val = $where;
$description = "Check for $val within $timevalue $timeframe";
$var = "this_trail";
#$expected = [re(qr(\d+)),re(qr(\d\d\d+) )];
$got = trail_element_within($domain,$rid,$session,$var,$val,$timevalue,$timeframe);
cmp_deeply($got,0,$description);
$test_count++;

$description = "Remove element from a trail";
$var = "this_trail";
$val = $who;
$expected = bag(
    [$where, re(qr/\d+/)],
    [$what, re(qr/\d+/)],
);
$got = delete_trail_element($domain,$rid,$session,$var,$val);
cmp_deeply($got,$expected,$description);
$test_count++;

$description = "Delete value from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

$var = $what;
$description = "Touch a variable ($var)";
$got = touch_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,0,$description);
$test_count++;

$description = "Delete value ($var) from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

#Log::Log4perl->easy_init($DEBUG);
$var = "stack";
for my $i (0 .. $stack_size) {
    $logger->debug($i);
    my $struct = {
        "index" => $i,
        $i => $who
    };
    add_trail_element($domain,$rid,$session,$var,$struct);
}

$description = "Shift a value off the stack";
$expected = {
    "index" => 0,
    0 => $who
};
$got = consume_trail_element($domain,$rid,$session,$var,1);
cmp_deeply($got,$expected,$description);
$test_count++;

$description = "Pop a value off the stack";
$expected = {
    "index" => $stack_size,
    $stack_size => $who
};
$got = consume_trail_element($domain,$rid,$session,$var,0);
cmp_deeply($got,$expected,$description);
$test_count++;


$description = "Pop a value off the stack";
$expected = {
    "index" => $stack_size-1,
    $stack_size-1 => $who
};
$got = consume_trail_element($domain,$rid,$session,$var,0);
cmp_deeply($got,$expected,$description);
$test_count++;

$description = "Delete value ($var) from mongo";
delete_persistent_var($domain,$rid,$session,$var);
$got = get_persistent_var($domain,$rid,$session,$var);
cmp_deeply($got,undef,$description);
$test_count++;

ENDY:

# Hash referencing operations
#Log::Log4perl->easy_init($DEBUG);

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
	'i' => {
		'j' => 8.1,
		'k' => [9, 10, 11],
		'l' => {
			'm' => 12,
			'o' => 'monkeys'
		}
	},
	'p' => 'dummy'
};

my $subhash = {
	'ping' => 'pong',
	'x' => {
		'd' => 1.3
	}
};

my $hash_var = "aaBaa";

foreach my $domain ('ent', 'app') {
	$logger->debug($domain);
	my $result;
	my $description;
	my $path;
	my $replace;
	my $dupe;
	
	diag "Inserting new HASH ($domain)";
	$description = "insert the whole hash ($domain)";
	$result = Kynetx::Persistence::save_persistent_var($domain,$rid,$session,$hash_var,$tricky_hash);
	cmp_deeply($result,$tricky_hash,$description);
	$test_count++;
	
	$description = "Pull the hash out ($domain)";
	$result = Kynetx::Persistence::get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($result,$tricky_hash,$description);
	$test_count++;
	
	$description = "Pull an element (scalar) ($domain)";
	$path = ['a'];
	$result = Kynetx::Persistence::get_persistent_hash_element($domain,$rid,$session,$hash_var,$path);
	cmp_deeply($result,$tricky_hash->{'a'},$description);
	$test_count++;

	$description = "Pull an element (hash) ($domain)";
	$path = ['i', 'l'];
	$result = Kynetx::Persistence::get_persistent_hash_element($domain,$rid,$session,$hash_var,$path);
	cmp_deeply($result,$tricky_hash->{'i'}->{'l'},$description);
	$test_count++;

	$description = "Pull an element (array) ($domain)";
	$path = ['i', 'k'];
	$result = Kynetx::Persistence::get_persistent_hash_element($domain,$rid,$session,$hash_var,$path);
	cmp_deeply($result,$tricky_hash->{'i'}->{'k'},$description);
	$test_count++;
	
	$description = "Insert an element ($domain)";
	$replace = "frumptious";
	$dupe = clone ($tricky_hash);
	$dupe->{'new'} = $replace;
	$path = ['new'];
	Kynetx::Persistence::save_persistent_hash_element($domain,$rid,$session,$hash_var,$path,$replace);
	$result = Kynetx::Persistence::get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($result,$dupe,$description);
	$test_count++;
	
	$description = "Replace a hash element (scalar) ($domain)";
	$dupe->{'i'} = $replace;
	$path = ['i'];
	Kynetx::Persistence::save_persistent_hash_element($domain,$rid,$session,$hash_var,$path,$replace);
	$result = Kynetx::Persistence::get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($result,$dupe,$description);
	$test_count++;
	
	$description = "Insert an element (hash) ($domain)";
	$replace = $subhash;
	$dupe->{'newer'} = $replace;
	$path = ['newer'];
	Kynetx::Persistence::save_persistent_hash_element($domain,$rid,$session,$hash_var,$path,$replace);
	$result = Kynetx::Persistence::get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($result,$dupe,$description);
	$test_count++;
	
	$description = "Replace a hash element (hash) ($domain)";
	$dupe->{'i'} = $replace;
	$path = ['i'];
	Kynetx::Persistence::save_persistent_hash_element($domain,$rid,$session,$hash_var,$path,$replace);
	$result = Kynetx::Persistence::get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($result,$dupe,$description);
	$test_count++;
	
	$description = "Delete a hash element ($domain)";
	delete $dupe->{'i'};
	$path = ['i'];
	Kynetx::Persistence::delete_persistent_hash_element($domain,$rid,$session,$hash_var,$path,$replace);
	$result = Kynetx::Persistence::get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($result,$dupe,$description);
	$test_count++;
	
	#### Clean up
	
	$description = "Delete value ($hash_var) from mongo ($domain)";
	delete_persistent_var($domain,$rid,$session,$hash_var);
	$got = get_persistent_var($domain,$rid,$session,$hash_var);
	cmp_deeply($got,undef,$description);
	$test_count++;
	
	$description = "Check that hash elements are deleted ($domain)";
	$path = ['a'];
	$got = get_persistent_var($domain,$rid,$session,$hash_var,$path);
	cmp_deeply($got,undef,$description);
	$test_count++;
	
}



done_testing($test_count);



1;


