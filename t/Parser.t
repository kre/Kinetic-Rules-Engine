#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/*.krl>;

# all the files in the rules repository
#my @krl_files = @ARGV ? @ARGV : </web/work/krl.kobj.net/rules/client/*.krl>;

# testing some...
# my @krl_files = <new/ineq[0-0].krl>;
#my @krl_files = <new/*.krl>;

use Test::More;
plan tests => $#krl_files+1;
use Test::LongString;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

foreach my $f (@krl_files) {
    my ($fl,$krl_text) = getkrl($f);

  
    my $result = parse_ruleset($krl_text);
    ok(! defined ($result->{'error'}), "$f: $fl")
}


1;


