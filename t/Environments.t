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
use Kynetx::JavaScript qw/:all/;



plan tests => 10;


my $e = empty_rule_env();

$e = extend_rule_env($e,['a','b'],[1,2]);

is(lookup_rule_env($e,'a'),1, 'lookup a');
is(lookup_rule_env($e,'b'),2, 'lookup a');
is(lookup_rule_env($e,'c'),undef, 'lookup a');

my $e1 = extend_rule_env($e,['a'], [3]);
is(lookup_rule_env($e1,'a'),3, 'lookup a in e1 after extending');
is(lookup_rule_env($e1,'b'),2, 'lookup b in e1 after extending');

my $e2 = extend_rule_env($e,['a'], [4]);
is(lookup_rule_env($e2,'a'),4, 'lookup a in e2 after extending');

is(lookup_rule_env($e1,'a'),3, 'is a still 3?');
is(lookup_rule_env($e,'a'),1, 'is a still 1?');

my $e3 = extend_rule_env($e,'c', [3]);

#diag Dumper($e3);
is_deeply(lookup_rule_env($e3,'c'),[3], 'lookup an array in e3 after extending');

my $e4 = extend_rule_env($e,['c'], [[3]]);

#diag Dumper($e3);
is_deeply(lookup_rule_env($e4,'c'),[3], 'lookup an array in e3 after extending');






1;


