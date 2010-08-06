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
plan tests => 7;
use Test::LongString;

use Kynetx::Test qw/:all/;
use Kynetx::Util qw/:all/;
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


