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

use APR::URI;
use APR::Pool ();
use Cache::Memcached;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use LWP::UserAgent;

use Kynetx::Configure;
use Kynetx::Repository qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Rids qw/:all/;
use Kynetx::Test qw/:all/;

# configure KNS

Kynetx::Configure::configure();

Kynetx::Memcached->init();

my $req_info = Kynetx::Test::gen_req_info('cs_test');

my $test_count = 0;

my $numtests = 66;

# configure KNS
Kynetx::Configure::configure();

my $broot = Kynetx::Configure::get_config("EVAL_HOST");
my $bport = Kynetx::Configure::get_config("OAUTH_CALLBACK_PORT") || "80";

#plan tests => $numtests;

#my $ruleset_base = "http://127.0.0.1/ruleset";
#my $event_base = "http://127.0.0.1/blue/event";
my $ruleset_base = "http://$broot:$bport/ruleset";
my $event_base = "http://$broot:$bport/blue/event";

my $rid = 'cs_test';

my $mech = Test::WWW::Mechanize->new();

diag "Using ruleset base: $ruleset_base";
diag "Using event base: $event_base";

diag "Warning: running these tests on a host without memcache support is slow...";
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$ruleset_base/version/$rid";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $numtests unless $response->is_success;

    # test CONSOLE function
    my $url_console_1 = "$ruleset_base/console/$rid?caller=http://www.windley.com/foo/bazz.html";
    diag "Testing console with $url_console_1";

    $mech->get_ok($url_console_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('Show Context');

    $mech->content_like('/Context for Client ID cs_test.prod/');
    $mech->content_like('/Active rules.+2/s');
    $mech->content_contains('test_rule_2');
    $mech->content_contains('will not fire');
    $test_count += 7;

    # test CONSOLE function
    my $url_console_2 = "$ruleset_base/console/$rid?caller=http://www.windley.com/foo/bar.html";
#    diag "Testing console with $url_console_2";

    $mech->get_ok($url_console_2);
    is($mech->content_type(), 'text/html');

    $mech->title_is('Show Context');

    $mech->content_like('/Context for Client ID cs_test.prod/');
    $mech->content_like('/Active rules.+\d+/s');
    $mech->content_contains('test_rule_1');
    $mech->content_contains('will fire');
    $test_count += 7;


    # test DESCRIBE function
    my $url_describe_1 = "$ruleset_base/describe/$rid";

#    diag "Testing console with $url_describe_1";

    $mech->get_ok($url_describe_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('Describe Ruleset cs_test');

    $mech->content_like('/"ruleset_version"\s*:\s*"(prod|\d+)"/s');
    $mech->content_like('/"description"\s*:\s*"[^"]+"/s');
    $mech->content_like('/"ruleset_id"\s*:\s*"[^"]+"/s');
    $test_count += 6;


    # test DESCRIBE function
    my $url_describe_2 = "$ruleset_base/describe/$rid?flavor=json";

    #diag "Testing console with $url_describe_2";

    $mech->get_ok($url_describe_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/"ruleset_version"\s*:\s*"(prod|\d+)"/s');
    $mech->content_like('/"description"\s*:\s*"[^"]+"/s');
    $mech->content_like('/"ruleset_id"\s*:\s*"[^"]+"/s');
    $test_count += 5;


    # test DESCRIBE function
    my $url_describe_3 = "$ruleset_base/describe/$rid?$rid:kynetx_app_version=dev";

    #diag "Testing console with $url_describe_3";

    $mech->get_ok($url_describe_3);
    is($mech->content_type(), 'text/html');

    $mech->content_like('/"ruleset_version"\s*:\s*"(dev|\d+)"/s');
    $mech->content_like('/"description"\s*:\s*"[^"]+"/s');
    $mech->content_like('/"ruleset_id"\s*:\s*"[^"]+"/s');
    $test_count += 5;


    # test DESCRIBE function
    my $url_describe_4 = "$ruleset_base/describe/$rid?$rid:kynetx_app_version=dev&flavor=json";

#    diag "Testing console with $url_describe_4";

    $mech->get_ok($url_describe_4);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/"ruleset_version"\s*:\s*"(dev|\d+)"/s');
    $mech->content_like('/"description"\s*:\s*"[^"]+"/s');
    $mech->content_like('/"ruleset_id"\s*:\s*"[^"]+"/s');
    $test_count += 5;



    # test FLUSH function

    my $url_2 = "$ruleset_base/flush/cs_test";
    # diag "Testing flush with $url_2";

    # make sure the ruleset is in the cache
    my $memd = get_memd();
    my $rid_info = mk_rid_info($req_info, 'cs_test'); # the test rid_info.  
    $req_info->{'rid'} = $rid_info;
    my $rules =  Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);

    my $rs_key = Kynetx::Repository::make_ruleset_key('cs_test', 'prod');
    my $ruleset = $memd->get($rs_key);
    ok(defined $ruleset, "Ruleset is cached");

    $mech->get_ok($url_2);

    is($mech->content_type(), 'text/html');
    $mech->content_like('/rules flushed/i');

    $ruleset = $memd->get($rs_key);
    ok(!defined $ruleset, "Ruleset is not cached");

    # now put it back
    $rules =  Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);
    

    $test_count += 5;

    my $url_2a = "$ruleset_base/flush/cs_test?cs_test:kinetic_app_version=dev";
    # diag "Testing flush with $url_2a";

    # make sure the ruleset is in the cache
    $rid_info = mk_rid_info($req_info, 'cs_test', {'version'=>'dev'}); # the test rid_info.  
    $req_info->{'rid'} = $rid_info;
    $rules =  Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);

    $rs_key = Kynetx::Repository::make_ruleset_key('cs_test', 'dev');
    $ruleset = $memd->get($rs_key);
    ok(defined $ruleset, "Ruleset is cached");

    $mech->get_ok($url_2a);

    is($mech->content_type(), 'text/html');
    $mech->content_like('/rules flushed/i');

    $ruleset = $memd->get($rs_key);
    ok(!defined $ruleset, "Ruleset is not cached");

    # now put it back
    $rules =  Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);
    

    $test_count += 5;

    # test EVAL function

    my $url_3 = "$ruleset_base/eval/$rid/1231363179515.js?caller=http%3A//www.windley.com/foo/bar.html&referer=http%3A//www.windley.com/&kvars=%7B%22foo%22%3A%205%2C%20%22bar%22%3A%20%22fizz%22%2C%20%22bizz%22%3A%20%5B1%2C%202%2C%203%5D%7D&title=Phil%20Windleys%20Technometria";
#    diag "Testing eval with $url_3";

    $mech->get_ok($url_3);


    is($mech->content_type(), 'text/javascript');

#diag $mech->content();

    $mech->content_like("/var x = 'foo';/");

    $mech->content_like('/function callBacks/');
    $mech->content_like('/function\(uniq, cb,/');
    $test_count += 5;

    # test web event

    my $url_3a = "$event_base/web/pageview/$rid/1231363179515.js?caller=http%3A//www.windley.com/foo/bar.html&referer=http%3A//www.windley.com/&kvars=%7B%22foo%22%3A%205%2C%20%22bar%22%3A%20%22fizz%22%2C%20%22bizz%22%3A%20%5B1%2C%202%2C%203%5D%7D&title=Phil%20Windleys%20Technometria";
#    diag "Testing eval with $url_3a";

    $mech->get_ok($url_3a);


    is($mech->content_type(), 'text/javascript');

#    diag $mech->content();

     $mech->content_like("/var x = 'foo';/");

    $mech->content_like('/function callBacks/');
    $mech->content_like('/function\(uniq, cb,/');
    $test_count += 5;

    # sets search referer
    my $url_4 = "$ruleset_base/eval/$rid/1231363179515.js?caller=http%3A//www.windley.com/foo/bazz.html&referer=http%3A//www.google.com/&kvars={%22foo%22%3A%205%2C%20%22bar%22%3A%20%22fizz%22%2C%20%22bizz%22%3A%20[1%2C%202%2C%203]}&title=Phil%20Windleys%20Technometria";

#    diag "Testing eval with $url_4";
    $mech->get_ok($url_4);


    is($mech->content_type(), 'text/javascript');

    # should be two actions, one callback
    $mech->content_like('/test_rule_2/s');
    $mech->content_like('/function callBacks/');
    $mech->content_like('/function\(uniq, cb,.+function\(uniq, cb,/s');
    # test_rule_3 shouldn't fire...inactive
    $mech->content_unlike('/test_rule_3/s');

    $mech->content_contains('kobj_weather');

    # globals
    $mech->content_contains('var foobar = 4;');

    $mech->content_contains(q/KOBJ['data']['public_timeline'] = [/);
    $mech->content_lacks("KOBJ['data']['cached_timeline'] =");
    $test_count += 10;

    # sets search referer with events
    my $url_4a = "$event_base/web/pageview/$rid/1231363179515.js?caller=http%3A//www.windley.com/foo/bazz.html&referer=http%3A//www.google.com/&kvars={%22foo%22%3A%205%2C%20%22bar%22%3A%20%22fizz%22%2C%20%22bizz%22%3A%20[1%2C%202%2C%203]}&title=Phil%20Windleys%20Technometria";

#    diag "Testing eval with $url_4a";

    $mech->get_ok($url_4a);


    is($mech->content_type(), 'text/javascript');

    # should be two actions, one callback
    $mech->content_like('/function callBacks/');
    $mech->content_like('/function\(uniq, cb,.+function\(uniq, cb,/s');

    $mech->content_contains('kobj_weather');

    # globals
    $mech->content_contains('var foobar = 5;');

    $mech->content_contains(q/KOBJ['data']['public_timeline'] = [/);
    $mech->content_lacks("KOBJ['data']['cached_timeline'] =");
    $test_count += 8;

    my $url_5 = "$ruleset_base/eval/$rid/1237475272090.js?caller=http%3A//search.barnesandnoble.com/booksearch/isbnInquiry.asp%3FEAN%3D9781400066940&referer=http%3A//www.barnesandnoble.com/index.asp&kvars=&title=Stealing MySpace, Julia Angwin, Book - Barnes & Noble";

    $mech->get_ok($url_5);

    is($mech->content_type(), 'text/javascript');
    $test_count += 2;



}

done_testing($test_count);

1;


