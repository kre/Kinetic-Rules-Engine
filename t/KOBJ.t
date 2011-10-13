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
use Test::WWW::Mechanize;

use LWP::UserAgent;
use Cache::Memcached;

use Apache2::Const;
use APR::URI;
use APR::Pool;

use Kynetx::Test;
use Kynetx::Parser;
use Kynetx::KOBJ;
use Kynetx::Repository;
use Kynetx::Memcached;
use Kynetx::FakeReq;


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

# my $numtests = 18;
# plan tests => $numtests;


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);


#my $my_req_info;
#$my_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)

# configure KNS
Kynetx::Configure::configure();

#Kynetx::Memcached->init();

my $test_count = 0;

my $dn = "http://127.0.0.1/js";

my $ruleset = $rid;



my $mech = Test::WWW::Mechanize->new();

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$ruleset";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", 0 if (! $response->is_success);

    # test version function
    my $url_version_1 = "$dn/version/$ruleset";
    #diag "Testing console with $url_version_1";

    $mech->get_ok($url_version_1);
    is($mech->content_type(), 'text/html');
#    $mech->title_is('KNS Version');
    $mech->content_like('/number\s+[\da-f]+/');
    $test_count += 3;


    my $url_version_2 = "$dn/version/$ruleset?flavor=json";
#    diag "Testing console with $url_version_2";

    $mech->get_ok($url_version_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/{"build_num"\s*:\s*"[\da-f]+/');
    $test_count += 3;

    # kobj.js
    my $url_version_3 = "$dn/$ruleset/kobj.js";
    #diag "Testing console with $url_version_3";

    $mech->get_ok($url_version_3);
    is($mech->content_type(), 'text/javascript');

    $mech->content_like(qr/var KOBJ= KOBJ || {\s*version:\s*'\d+\.\d+'\s*}/s);
    $test_count += 3;


    # dispatch
    my $url_version_4 = "$dn/dispatch/cs_test;cs_test_1/";
    diag "Testing dispatch with $url_version_4";

    $mech->get_ok($url_version_4);
    is($mech->content_type(), 'text/plain');

    $mech->content_like(qr/www\.windley\.com.*www\.yahoo\.com/s);
    $test_count += 3;

    # datasets
    my $url_version_5 = "$dn/datasets/cs_test;cs_test_1/";
    diag "Testing datasets with $url_version_5";

    $mech->get_ok($url_version_5);
    is($mech->content_type(), 'text/javascript');

    $mech->content_contains("KOBJ['data']['cached_timeline'] =");
    $mech->content_lacks("KOBJ['data']['public_timeline'] =");
    $test_count += 4;


}

done_testing($test_count);

1;


