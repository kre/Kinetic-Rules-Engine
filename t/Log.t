#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 5;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Log qw/:all/;


is(Kynetx::Log::array_to_string(["foo", "bar"]), "[foo,bar]", 
   "array to string with array");

is(Kynetx::Log::array_to_string([]), "[]", "array to string with undef");

is(Kynetx::Log::array_to_string(undef), "[]", "array to string with undef");

is(Kynetx::Log::array_to_string("foo"), "[]", "array to string with string");

is(Kynetx::Log::array_to_string(5), "[]", "array to string with number");

1;


