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
my @krl_files = @ARGV ? @ARGV : <data/*.krl>;

# all the files in the rules repository
#my @krl_files = @ARGV ? @ARGV : </web/work/krl.kobj.net/rules/client/*.krl>;

# testing some...
#my @krl_files = <new/*.krl>;


use Test::More;
use Test::LongString;
use Data::Dumper;
use Encode;

use Kynetx::Test qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Parser qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

my $skip = {"data/events12.krl" => 1,
	    "data/events13.krl" => 1,
	    "data/operator2.krl" => 1,
	    "data/schedule3.krl" => 1,
	   };


plan tests => $#krl_files-(length(keys %{$skip}))+2;


foreach my $f (@krl_files) {
   #diag $f;
    next if ($f =~ m/exprs\d/); # exprs don't pretty print exactly
    next if ($skip->{$f});
    my ($fl,$krl_text) = getkrl($f);
    my $tree = parse_ruleset($krl_text);
    $logger->debug("$fl: ", sub {Dumper($tree)});
    # compare to text with comments removed since pp can't reinsert them.
    # Use the internal perl string structure for the compare
    my $krl = decode("UTF-8",$krl_text);
    my $result = is_string_nows(decode("UTF-8",pp($tree)), remove_comments($krl), "$f: $fl");
    die unless ($result);
}


my ($fl,$krl_text);

($fl, $krl_text) = getkrl("data/comment1.krl_");
my $krl = decode("UTF-8",$krl_text);
#diag $krl;
#diag remove_comments($krl);

like(remove_comments($krl), qr/exec/, "Escaped slashes don't count");

unlike(remove_comments($krl), qr/comment offset/, "offset comments are removed");

like(remove_comments($krl), qr/comment in extended quote/, "don't remove extended quotes");

unlike(remove_comments($krl), qr/start of line/, "don't remove extended quotes");
unlike(remove_comments($krl), qr/JS comment/, "clownhats don't protect");

like(remove_comments($krl), qr/http:\/\/www.windley.com/, "double quotes protect");



1;


