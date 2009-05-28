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


plan tests => 10;


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






1;


