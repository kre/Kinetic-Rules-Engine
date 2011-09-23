#!/usr/bin/perl -w
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
use lib qw(/web/lib/perl);
use strict;

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/fails/*.krlb>;


use Test::More;
plan tests => $#krl_files+1;
use Test::LongString;
use Data::Dumper;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

foreach my $f (@krl_files) {
    my ($fl,$krl_text) = getkrl($f);
    my $result = parse_ruleset($krl_text);
    $logger->debug("Parsed: $f: $fl");
    $logger->debug("Error: ", sub {Dumper($result)});
    ok(defined ($result->{'error'}), "$f: $fl")
}


1;


