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
use warnings;

use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::System::Ruleset qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;
my $r = Kynetx::Test::configure();


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $memd = Kynetx::Memcached::get_memd();

my $test_count = 0;

my ($status, $result, $expected, $path, $desc, $extended_path, $extended_expected);

$desc = "simple value at root";
$expected = 10;
$path = [];
$status = Kynetx::System::Ruleset::write("flip", $path, $expected);
ok($status, $desc);
$result =  Kynetx::System::Ruleset::read("flip",$path);
is($result, $expected, $desc);
$test_count += 2;

$desc = "simple value at [key0]";
$expected = 10;
$path = ["key0"];
$status = Kynetx::System::Ruleset::write("flip", $path, $expected);
ok($status, $desc);
$result =  Kynetx::System::Ruleset::read("flip",$path);
is($result, $expected, $desc);
$test_count += 2;

$desc = "hash value at [key1]";
$expected = {"foo" => 10, "bar" => "bird"};
$path = ["key1"];
$extended_path = ["key1","bar"];
$extended_expected = "bird";
$status = Kynetx::System::Ruleset::write("flip", $path, $expected);
ok($status, $desc);
$result =  Kynetx::System::Ruleset::read("flip",$path);
is_deeply($result, $expected, "result for ". $desc);
$result =  Kynetx::System::Ruleset::read("flip",$extended_path);
is_deeply($result, $extended_expected, "exteneded path result for ". $desc);
$test_count += 3;

$desc = "delete simple value at [key0]";
$expected = undef;
$path = ["key0"];
$status = Kynetx::System::Ruleset::delete("flip", $path);

ok($status, $desc . ": status");
$result =  Kynetx::System::Ruleset::read("flip",$path);
is($result, $expected, $desc. ": value");
$test_count += 2;

$desc = "delete simple value at [key1,foo]";
$path = ["key1","foo"];
$status = Kynetx::System::Ruleset::delete("flip", $path);

ok($status, $desc . ": status");
$result =  Kynetx::System::Ruleset::read("flip",$path);
$expected = undef;
is($result, $expected, $desc. ": value");
$extended_path = ["key1","bar"];
$result =  Kynetx::System::Ruleset::read("flip",$extended_path);
$expected = "bird";
is_deeply($result, $expected, "result for ". $desc);
$test_count += 3;


$desc = "delete entire var";
$status = Kynetx::System::Ruleset::delete("flip");
ok($status, $desc . ": status");
$expected = undef;
$result =  Kynetx::System::Ruleset::read("flip",[]);
is($result, $expected, $desc. ": value");
$test_count += 2;



# TODO: 
# - cleanup, delete

done_testing($test_count);



1;


