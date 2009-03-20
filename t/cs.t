#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;

use LWP::UserAgent;

my $numtests = 41;

plan tests => $numtests;

my $dn = "http://127.0.0.1/ruleset";

my $ruleset = 'cs_test';

my $mech = Test::WWW::Mechanize->new();

diag "Warning: running these tests on a host without memcache support is slow...";
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$ruleset";
#    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $numtests unless $response->is_success;

    # test CONSOLE function
    my $url_console_1 = "$dn/console/$ruleset?caller=http://www.windley.com/foo/bazz.html";
    #diag "Testing console with $url_console_1";

    $mech->get_ok($url_console_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('Show Context');

    $mech->content_like('/Context for Client ID cs_test/');
    $mech->content_like('/Active rules.+2/s');
    $mech->content_contains('test_rule_2');
    $mech->content_contains('will not fire');


    # test CONSOLE function
    my $url_console_2 = "$dn/console/$ruleset?caller=http://www.windley.com/foo/bar.html";
    #diag "Testing console with $url_console_2";

    $mech->get_ok($url_console_2);
    is($mech->content_type(), 'text/html');

    $mech->title_is('Show Context');

    $mech->content_like('/Context for Client ID cs_test/');
    $mech->content_like('/Active rules.+2/s');
    $mech->content_contains('test_rule_1');
    $mech->content_contains('will fire');


    # test DESCRIBE function
    my $url_describe_1 = "$dn/describe/$ruleset";

    #diag "Testing console with $url_describe_1";

    $mech->get_ok($url_describe_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('Describe Ruleset cs_test');

    $mech->content_like('/"ruleset_version"\s*:\s*"\d+"/s');
    $mech->content_like('/"description"\s*:\s*"[^"]+"/s');
    $mech->content_like('/"ruleset_id"\s*:\s*"[^"]+"/s');


    # test DESCRIBE function
    my $url_describe_2 = "$dn/describe/$ruleset?flavor=json";

    #diag "Testing console with $url_describe_2";

    $mech->get_ok($url_describe_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/"ruleset_version"\s*:\s*"\d+"/s');
    $mech->content_like('/"description"\s*:\s*"[^"]+"/s');
    $mech->content_like('/"ruleset_id"\s*:\s*"[^"]+"/s');



    # test FLUSH function

    my $url_2 = "$dn/flush/$ruleset";
    # diag "Testing flush with $url_2";

    $mech->get_ok($url_2);

    is($mech->content_type(), 'text/html');
    $mech->content_like('/rules flushed/i');

    # test EVAL function

    my $url_3 = "$dn/eval/$ruleset/1231363179515.js?caller=http%3A//www.windley.com/foo/bar.html&referer=http%3A//www.windley.com/&kvars=%7B%22foo%22%3A%205%2C%20%22bar%22%3A%20%22fizz%22%2C%20%22bizz%22%3A%20%5B1%2C%202%2C%203%5D%7D&title=Phil%20Windleys%20Technometria";
    #diag "Testing eval with $url_3";

    $mech->get_ok($url_3);


    is($mech->content_type(), 'text/javascript');

    $mech->content_like('/function callBacks\d+/');
    $mech->content_like('/function\(uniq, cb,/');

    # sets search referer
    my $url_4 = "$dn/eval/$ruleset/1231363179515.js?caller=http%3A//www.windley.com/foo/bazz.html&referer=http%3A//www.google.com/&kvars={%22foo%22%3A%205%2C%20%22bar%22%3A%20%22fizz%22%2C%20%22bizz%22%3A%20[1%2C%202%2C%203]}&title=Phil%20Windleys%20Technometria";

#    diag "Testing eval with $url_4";

    $mech->get_ok($url_4);


    is($mech->content_type(), 'text/javascript');

    # should be two actions, one callback
    $mech->content_like('/function callBacks\d+/');
    $mech->content_like('/function\(uniq, cb,.+function\(uniq, cb,/s');

    $mech->content_contains('kobj_weather');

    # globals
    $mech->content_contains('var foobar = 4;');

    $mech->content_contains('var public_timeline = [{"user":{"followers_count":');

    my $url_5 = "$dn/eval/$ruleset/1237475272090.js?caller=http%3A//search.barnesandnoble.com/booksearch/isbnInquiry.asp%3FEAN%3D9781400066940&referer=http%3A//www.barnesandnoble.com/index.asp&kvars=&title=Stealing MySpace, Julia Angwin, Book - Barnes & Noble";


    $mech->get_ok($url_5);

    is($mech->content_type(), 'text/javascript');



}

1;


