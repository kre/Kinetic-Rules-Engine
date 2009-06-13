#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();

use Data::Dumper;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Environments qw/:all/;


plan tests => 19;


my $e = empty_rule_env();

$e = extend_rule_env(['a','b'],[1,2], $e);

is(lookup_rule_env('a',$e), 1, 'lookup a');
is(lookup_rule_env('b',$e), 2, 'lookup b');
#diag Dumper($e);

is(lookup_rule_env('c',$e), undef, 'lookup c');

my $e1 = extend_rule_env(['a'], [3], $e);
is(lookup_rule_env('a',$e1),3, 'lookup a in e1 after extending');
is(lookup_rule_env('b',$e1),2, 'lookup b in e1 after extending');

my $e2 = extend_rule_env(['a'], [4], $e);
is(lookup_rule_env('a',$e2),4, 'lookup a in e2 after extending');

is(lookup_rule_env('a',$e1),3, 'is a still 3?');
is(lookup_rule_env('a',$e),1, 'is a still 1?');

my $e3 = extend_rule_env('c', [3], $e);

#diag Dumper($e3);
is_deeply(lookup_rule_env('c',$e3),[3], 'lookup an array in e3 after extending');

my $e4 = extend_rule_env(['c'], [[3]], $e);

#diag Dumper($e3);
is_deeply(lookup_rule_env('c',$e4),[3], 'lookup an array in e3 after extending');


my $e5  = extend_rule_env({'a' => 5}, $e);
is(lookup_rule_env('a',$e5),5, 'lookup a in e5 after extending with a hash');

my $e6  = extend_rule_env({'a' => [5]}, $e);
is_deeply(lookup_rule_env('a',$e6),[5], 'lookup an array in e6 after extending with hash');


my $e7  = extend_rule_env({'a' => 5, 'd' => '5'}, $e);
is(lookup_rule_env('a',$e7),5, 'lookup a in e7 after extending with a hash');
is(lookup_rule_env('d',$e7),'5', 'lookup d in e7 after extending with a hash');


my $flat_e = {
           'a' => 1,
           'b' => 2,
	   '___order' => ['a','b']
         };

is_deeply(flatten_env($e), $flat_e, "Flattening creates correct scope for e");

my $flat_e1 = {
           'a' => 3,
           'b' => 2,
	   '___order' => ['b','a']
         };

is_deeply(flatten_env($e1), $flat_e1, "Flattening creates correct scope for e1");

my $flat_e2 = {
           'a' => 4,
           'b' => 2,
	   '___order' => ['b','a']
         };

is_deeply(flatten_env($e2), $flat_e2, "Flattening creates correct scope for e2");
#diag(Dumper(flatten_env($e2)));

my $flat_e3 = {
           'a' => 1,
           'b' => 2,
	   'c' => [3],
	   '___order' => ['a','b','c']
         };

is_deeply(flatten_env($e3), $flat_e3, "Flattening creates correct scope for e3");
#diag(Dumper(flatten_env($e3)));

my $flat_e6 = {
           'b' => 2,
	   'a' => [5],
	   '___order' => ['b','a']
         };

is_deeply(flatten_env($e6), $flat_e6, "Flattening creates correct scope for e6");
#diag(Dumper(flatten_env($e3)));


1;


