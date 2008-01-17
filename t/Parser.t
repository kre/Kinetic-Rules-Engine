#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/*.krl>;

use Test::More;
plan tests => $#krl_files+1;
use Test::LongString;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

foreach my $f (@krl_files) {
    my ($fl,$krl_text) = getkrl($f);
    
    ok(parse_ruleset($krl_text), "$f: $fl")
}


1;


