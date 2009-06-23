#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;

use LWP::UserAgent;
use Cache::Memcached;

use Apache2::Const;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::KOBJ qw/:all/;
use Kynetx::Repository qw/:all/;
use Kynetx::Memcached qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

my $numtests = 18;
plan tests => $numtests;



my $my_req_info;
$my_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)

# configure KNS
Kynetx::Configure::configure();

Kynetx::Memcached->init();


# dispatch
my $svn_conn = "http://krl.kobj.net/rules/client/|cs|fizzbazz";

is_string_nows(
    Kynetx::KOBJ::dispatch($my_req_info,"cs_test;cs_test_1",$svn_conn), 
    '{"cs_test_1":["www.windley.com","www.kynetx.com"],"cs_test":["www.google.com","www.yahoo.com","www.live.com"]}',
    "Testing dispatch function with two RIDs");



my $dn = "http://127.0.0.1/js";

my $ruleset = "cs_test";



my $mech = Test::WWW::Mechanize->new();

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$ruleset";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $numtests if (! $response->is_success);

    # test version function
    my $url_version_1 = "$dn/version/$ruleset";
    #diag "Testing console with $url_version_1";

    $mech->get_ok($url_version_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('KNS Version');

    $mech->content_like('/number\s+\d+/');

    my $url_version_2 = "$dn/version/$ruleset?flavor=json";
    #diag "Testing console with $url_version_2";

    $mech->get_ok($url_version_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/{"build_num"\s*:\s*"\d+/');

    # kobj.js
    my $url_version_3 = "$dn/$ruleset/kobj.js";
    #diag "Testing console with $url_version_3";

    $mech->get_ok($url_version_3);
    is($mech->content_type(), 'text/javascript');

    $mech->content_like(qr/var KOBJ= KOBJ || {\s*version:\s*'\d+\.\d+'\s*}/s);


    # dispatch
    my $url_version_4 = "$dn/dispatch/cs_test;cs_test_1/";
    diag "Testing dispatch with $url_version_4";

    $mech->get_ok($url_version_4);
    is($mech->content_type(), 'text/plain');

    $mech->content_like(qr/www\.windley\.com.*www\.yahoo\.com/s);

    # datasets
    my $url_version_5 = "$dn/datasets/cs_test;cs_test_1/";
    diag "Testing datasets with $url_version_5";

    $mech->get_ok($url_version_5);
    is($mech->content_type(), 'text/javascript');

    $mech->content_contains("KOBJ['data']['cached_timeline'] =");
    $mech->content_lacks("KOBJ['data']['public_timeline'] =");


}


1;


