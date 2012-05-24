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

use Test::More;

use Test::LongString;
use Test::Deep;
use Apache::Session::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::FakeReq;
use DateTime;
use Data::Dumper;
use Kynetx::Metrics::TENX qw(:all);
use Cache::Memcached;
use Benchmark ':hireswallclock';
use Clone qw(clone);
use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached;
use APR::URI qw/:all/;
use APR::Pool ();


use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->easy_init($DEBUG);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($TRACE);
my $logger = get_logger();

Kynetx::Configure::configure();

Kynetx::MongoDB::init();

Kynetx::Memcached->init();


my $num_test = 1;
my $rid = "time_test";
my $session = int(rand(1000000)); 

ok(1);




done_testing($num_test);

1;


