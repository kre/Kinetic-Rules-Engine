#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 4;
use Test::LongString;

use Kynetx::Test qw/:all/;
use Kynetx::Util qw/:all/;
use DateTime;


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

# before_now
my $after = DateTime->now->add( days => 1 );
my $before = DateTime->now->add( days => -1 );

#diag("Now $now");
#diag("Before $before");
#diag("After $after");

ok(before_now($before), "before_now: before");
ok(!before_now($after), "before_now: after");

# after_now
ok(after_now($after), "after_now: after");
ok(!after_now($before), "after_now: before");

1;


