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
plan tests => $numtests + 5;

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
        click class="newsletter" triggers ent:archive_pages_now -= 2 from 1;
        click class="flipper"
      } 
    }
  }
}
_KRL_
$ruleset = Kynetx::Parser::parse_ruleset($krl_src);
#diag Dumper($ruleset);

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

Kynetx::Callbacks::process_callbacks($ruleset,
				     'test0',
				     'failure',
				     'click',
				     'flipper',
				     $req_info,
				     $session);
				     
is(session_get($rid, $session, 'archive_pages_now'),
   1,
   "incrementing archive pages unchanged"
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

    $mech->content_like('/number\s+[\da-f]+/');

    my $url_version_2 = "$dn/version/$rid?flavor=json";
    #diag "Testing console with $url_version_2";

    $mech->get_ok($url_version_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/{"build_num"\s*:\s*"[\da-f]+/');

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


