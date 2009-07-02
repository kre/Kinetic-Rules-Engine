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
use Test::LongString;

use Cache::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Configure;

my $logger = get_logger();

my $numtests = 5;
plan tests => $numtests;

my $config_file = "/web/etc/kns_config.yml";

ok(-f $config_file, "Does the config file exist?");

Kynetx::Configure::configure();

SKIP: {
    skip "No config file available", $numtests-1 if (! -f $config_file);

    Kynetx::Memcached->init();

    my $memd = get_memd();

    my $now = time();

    $memd->set("test1", $now);

    is($memd->get("test1"), $now, "Did it get stored?");

    $memd->delete("test1");

    is($memd->get("test1"), undef, "Did it get deleted?");


    my $content = get_remote_data('http://twitter.com/statuses/public_timeline.json',1);
    contains_string(
	$content,
	'"text":',
	'Get public timeline');
    
    $content = get_remote_data('https://twitter.com/statuses/public_timeline.json',1);
    contains_string(
	$content,
	'"text":',
	'Get public timeline with HTTPS');
    
}

1;


