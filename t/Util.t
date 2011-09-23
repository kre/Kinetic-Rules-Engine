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
plan tests => 7;
use Test::LongString;
use Apache::Session::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::FakeReq;
use DateTime;


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

# before_now
my $after = DateTime->now->add( days => 1 );
my $before = DateTime->now->add( days => -1 );

#diag("Now $now");
#diag("Before $before");
#diag("After $after");

ok(before_now($before), "before_now: before");
ok(!before_now($after), "before_now: after");

# after_now
ok(after_now($after), "after_now: after");
ok(!after_now($before), "after_now: before");


my $url = 'http://www.windley.com/?';

my $url_options = {'A' => '1',
		   'B' => '2',
		   'C' => 'This is a test',
		  };


is(mk_url($url, $url_options), "http://www.windley.com/?A=1&C=This%20is%20a%20test&B=2");

$url = 'http://www.windley.com/';

$url_options = {'A' => '1',
		   'B' => '2',
		   'C' => 'This is a test',
		  };


is(mk_url($url, $url_options), "http://www.windley.com/?A=1&C=This%20is%20a%20test&B=2");

$url = 'http://www.windley.com/?A=1';

$url_options = {'B' => '2',
		'C' => 'This is a test',
	       };


is(mk_url($url, $url_options), "http://www.windley.com/?A=1&C=This%20is%20a%20test&B=2");

1;


