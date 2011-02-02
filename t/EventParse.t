#!/usr/bin/perl -w

#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#
use lib qw(/web/lib/perl);
use strict;


use Test::More;
use Test::Deep;
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);


use Kynetx::Test qw/:all/;
use Kynetx::JParser qw/:all/;
use Kynetx::OParser qw(:all);
use Kynetx::Configure;
use Kynetx::Json qw(:all);

Kynetx::Configure::configure();
my $logger = get_logger();

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/events/*.krl>;

my $debug = 1;

my @skips = qw(
    data/exprs0.krl
    data/regexp0.krl
    data/regexp1.krl
    data/regexp2.krl
    data/regexp3.krl
    data/regexp4.krl
    data/regexp5.krl
    data/regexp6.krl
    data/regexp7.krl
    data/regexp8.krl
    data/regexp9.krl
    data/counter2.krl
);

my $skip_list;
map {$skip_list->{$_} = 1} @skips;

$logger->debug("Skips: ", sub {Dumper($skip_list)});

my $num_tests = $#krl_files+1;
my $jparser = Kynetx::JParser::get_antlr_parser();
foreach my $f (@krl_files) {
    my ($fl,$krl_text) = getkrl($f);
    if ($debug) {
        diag $f;
    }
    if ($skip_list->{$f}) {
        diag "Skipping $f";
        $num_tests--;
        next;
    }
    my $ptree = $jparser->ruleset($krl_text);
    $logger->debug("Parse tree: ", sub {Dumper($ptree)});
}
plan tests => $num_tests;



1;


