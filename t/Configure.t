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

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::JavaScript qw/:all/;



plan tests => 11;


Kynetx::Configure::configure("./data/kns_config.yml");

is(get_config('KOBJ_ROOT'), '/web/lib/perl');

is(get_config('SERVER_ADMIN'), 'web@kynetx.com');

is(get_config('SESSION_SERVERS'), '127.0.0.1:11211 192.168.122.1:11211');

is_deeply(get_config('MEMCACHE_SERVERS'), ['127.0.0.1:11211']);

is(get_config('COOKIE_DOMAIN'), '127.0.0.1');

is(get_config('USE_CLOUDFRONT'), 0);

is(get_config('CACHEABLE_THRESHOLD'), 86400);

contains_string(join(" ", @{ config_keys() }), 'CB_HOST');
contains_string(join(" ", @{ config_keys() }), 'MAX_SERVERS');
contains_string(join(" ", @{ config_keys() }), 'SESSION_SERVERS');
contains_string(join(" ", @{ config_keys() }), 'EVAL_HOST');

1;


