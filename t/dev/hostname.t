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
use Test::WWW::Mechanize;
use Cache::Memcached;

use Socket;


use Kynetx::Configure qw/:all/;
use Kynetx::Test qw/:all/;
use Kynetx::FakeReq qw/:all/;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

my $r = Kynetx::Test::configure();

my $test_count = 0;

# the purpose of this test is to ensure that the platform, which many other tests
# rely on, is reachable and warn when it is not. 

diag "Running in " . Kynetx::Configure::get_config('RUN_MODE') . " mode";

my $platform = '127.0.0.1';
#my $platform = 'flipperoo.com';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
diag "Using $platform for testing";

my $ip_address;
my @packed_ip = gethostbyname($platform);
if (defined $packed_ip[0]) {
  $ip_address = $packed_ip[0];
} 

ok(defined $ip_address, "Is the needed platform available?");
$test_count++;

done_testing($test_count);

1;


