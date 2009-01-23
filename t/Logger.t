#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;

use LWP::UserAgent;

use Apache2::Const;

use Kynetx::Parser qw/:all/;
use Kynetx::Test qw/:all/;
use Kynetx::Logger qw/:all/;

my $numtests = 12;
plan tests => $numtests;

my $dn = "http://127.0.0.1/log";

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

    my $txn_id = "0123456789";
    my $url = "http://www.windley.com";
    my $sense = "success";
    my $type = "click";
    my $element = "foobar";
    my $rule = "10";

    my $url_version_3 = 
	"$dn/$ruleset?" .
	join("&",@{ ["txn_id=$txn_id",
		  "sense=$sense",
		  "type=$type",
		  "element=$element",
		  "rule=$rule",
	     ]});
    #diag "Testing console with $url_version_3";
    $mech->get_ok($url_version_3);
    is($mech->content_type(), 'text/javascript');
    
    my $url_version_4 = 
	"$dn/$ruleset?" .
	join("&",@{ ["txn_id=$txn_id",
		  "sense=$sense",
		  "type=$type",
		  "element=$element",
		  "rule=$rule",
		  "url=$url",
	     ]});
    #diag "Testing console with $url_version_4";
    $mech->get_ok($url_version_4);
    is($mech->content_type(), 'text/javascript');
    $mech->content_is("window.location = '$url'");

}


1;


