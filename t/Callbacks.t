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
use Test::WWW::Mechanize;
use Cache::Memcached;
use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use LWP::UserAgent;

use Apache2::Const;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Parser qw/:all/;
use Kynetx::Test qw/:all/;
use Kynetx::Callbacks qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;

use Kynetx::FakeReq;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

my $req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

# when callback evals trigger statements, there's no rule env
my $rule_env = Kynetx::Environments::empty_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);


my $numtests = 12;
plan tests => $numtests + 4;

my($krl_src, $ruleset);
#
# test callback trigger statements
#
$krl_src = <<_KRL_;
ruleset $rid {
  rule test0 is active {
    select using "/identity-policy/" setting ()

    noop();

    callbacks {
      success {
        click id="rssfeed" triggers clear ent:archive_pages_now ;
        click class="newsletter" triggers ent:archive_pages_now += 2 from 1
      } 
      failure {
        click class="newsletter" triggers ent:archive_pages_now -= 2 from 1
      } 
    }
  }
}
_KRL_
$ruleset = Kynetx::Parser::parse_ruleset($krl_src);

Kynetx::Callbacks::process_callbacks($ruleset,
				     'test0',
				     'success',
				     'click',
				     'newsletter',
				     $req_info,
				     $session);
				     
is(session_get($rid, $session, 'archive_pages_now'),
   4,
   "incrementing archive pages"
  );

Kynetx::Callbacks::process_callbacks($ruleset,
				     'test0',
				     'failure',
				     'click',
				     'newsletter',
				     $req_info,
				     $session);
				     
is(session_get($rid, $session, 'archive_pages_now'),
   2,
   "decrementing archive pages"
  );

Kynetx::Callbacks::process_callbacks($ruleset,
				     'test0',
				     'success',
				     'click',
				     'rssfeed',
				     $req_info,
				     $session);
				     
is(session_get($rid, $session, 'archive_pages_now'),
   undef,
   "clearing archive pages"
  );

Kynetx::Callbacks::process_callbacks($ruleset,
				     'test0',
				     'success',
				     'click',
				     'newsletter',
				     $req_info,
				     $session);
				     
is(session_get($rid, $session, 'archive_pages_now'),
   1,
   "incrementing archive pages from undef"
  );



#diag Dumper($session);
     



#
# test API
#
my $mech = Test::WWW::Mechanize->new();
my $dn = "http://127.0.0.1/log";


SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$rid";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $numtests if (! $response->is_success);

    # test version function
    my $url_version_1 = "$dn/version/$rid";
    #diag "Testing console with $url_version_1";

    $mech->get_ok($url_version_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('KNS Version');

    $mech->content_like('/number\s+\d+/');

    my $url_version_2 = "$dn/version/$rid?flavor=json";
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
    my $rid = "cs_test";

    my $url_version_3 = 
	"$dn/$rid?" .
	join("&",@{ ["txn_id=$txn_id",
		  "sense=$sense",
		  "type=$type",
		  "element=$element",
		  "rule=$rule",
		  "rid=$rid",
	     ]});
    #diag "Testing console with $url_version_3";
    $mech->get_ok($url_version_3);
    is($mech->content_type(), 'text/javascript');
    
    my $url_version_4 = 
	"$dn/$rid?" .
	join("&",@{ ["txn_id=$txn_id",
		  "sense=$sense",
		  "type=$type",
		  "element=$element",
		  "rule=$rule",
		  "rid=$rid",
		  "url=$url",
	     ]});
    #diag "Testing console with $url_version_4";
    $mech->get_ok($url_version_4);
    is($mech->content_type(), 'text/javascript');
    $mech->content_is("window.location.replace('$url');");

}



1;


