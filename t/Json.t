#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/*.krl>;

use Test::More;
plan tests => $#krl_files+1;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Json qw/:all/;

# test the round trip KRL -> Json -> KRL
foreach my $f (@krl_files) {
    my ($fl,$krl_text) = getkrl($f);
    my $json = krlToJson($krl_text);
    is_string_nows(jsonToKrl($json), $krl_text, "$f: $fl")
}

1;


