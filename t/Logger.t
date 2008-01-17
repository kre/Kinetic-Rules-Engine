#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 1;
use Test::LongString;

use Apache2::Const;

use Kynetx::Parser qw/:all/;
use Kynetx::Test qw/:all/;
use Kynetx::Logger qw/:all/;


ok(1,"dummy test");

1;


