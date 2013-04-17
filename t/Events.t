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
use warnings;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;
use HTTP::Cookies;
use Apache2::Const;
use Apache2::Request;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Events qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;

use Kynetx::Json qw/:all/;

use Kynetx::Parser;
use Kynetx::Rules;

use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();
my $r = Kynetx::Test::configure();
my $dp;
$dp = new Kynetx::Metrics::Datapoint;
$dp->start_timer();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;

my ($krl,$ast,$sm, $ev, $initial, $n1);

## test compile_event_expr

$my_req_info->{'domain'} = 'web';
$my_req_info->{'eventtype'} = 'pageview';

$krl = <<_KRL_;
rule foo is active {
  select when pageview "/archives/(\\d\\d\\d\\d)" setting(year)
  noop();
}
_KRL_

$my_req_info->{'caller'} = "http://www.windley.com/archives/2006/09/test.html";
$ev = mk_event($my_req_info);

$ast = Kynetx::Parser::parse_rule($krl);
$sm = compile_event_expr($ast->{'pagetype'}->{'event_expr'},{},$ast);

$initial = $sm->get_initial();
$n1 = $sm->next_state($initial, $ev);
$logger->debug("Initial: ", sub {Dumper($initial)});
$logger->debug("Next state: ", sub {Dumper($n1)});
$logger->debug("sm: ", sub {Dumper($sm)});
ok($sm->is_final($n1), "ev leads to final state");
$test_count++;

my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');

### NOTE: if the platform isn't right, then cookies won't work and these tests will fail

my $dn = "http://$platform/blue/event";

my $ruleset = 'cs_test_1';

my $mech = Test::WWW::Mechanize->new();

# should be empty
#diag Dumper $mech->cookie_jar();


diag "Warning: running these tests on a host without memcache support is slow...";
SKIP: {
    my $ua = LWP::UserAgent->new;
    my $check_url = "$dn/version/";

    my $response = $ua->get($check_url);
    unless ($response->is_success) {
      diag "skipping server tests: $check_url failed";
      skip "No server available", 0;
    }

    sub test_event_plan {
      my $test_plan = shift;
      my $tc = 0;
      foreach my $test (@{$test_plan}) {
    $logger->debug( "Requesting: ". $test->{'url'});
    my $resp;
    if (defined $test->{'method'} && $test->{'method'} eq 'post') {

      $resp = $mech->get($test->{'url'});
    } else {
      #$mech->get_ok($test->{'url'});
      $resp = $mech->get($test->{'url'});
    }

#    like($mech->status(), /2../, 'Status OK');
#    $tc++;
    ok($resp->header('Set-Cookie'), 'has cookie header');
    $tc++;
#    diag "Response header: ", $resp->as_string();
#    diag "Cookies: ", Dumper $mech->cookie_jar;
    like($mech->cookie_jar->as_string(), qr/SESSION_ID/, 'cookie was accepted');
    $tc++;


    diag $mech->content() if $test->{'diag'};
    is($mech->content_type(), $test->{'type'});
    $tc += 1;
    foreach my $like (@{$test->{'like'}}) {
      my $resp = $mech->content_like($like);
      if ($resp){
          $tc++;
      } else {
          diag $like;
          diag $mech->content();
          diag $test->{'url'};
          die;
      }

    }
    foreach my $unlike (@{$test->{'unlike'}}) {
      my $resp = $mech->content_unlike($unlike);
      if ($resp){
          $tc++;
      } else {
          diag $unlike;
          diag $mech->content();
          diag $test->{'url'};
          die;
      }
    }
      }

      return $tc;
    }

    # tests in an event plan are order dependent since events are order dependent.
    # Each plan is running different events in order to test a specific
    #   scenario defined in the rule's select statement
    
    my $after_test_plan = 
       [{'url' => "$dn/web/pageview/a144x132?caller=http://www.windley.com/first.html",
	'type' => 'text/javascript',
	'like' => ['/first page/']
       },
       {'url' => "$dn/web/pageview/a144x132?caller=http://www.windley.com/second.html",
	'type' => 'text/javascript',
	'like' => ['/second after first/',
		 ]
       }];
    
    $test_count += test_event_plan($after_test_plan);

    
    my $before_test_plan =
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/foo.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_4/',
		   '/var year = 2006/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/bar.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		 ]
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/foo.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_4/',
		  '/var year = 2006/',
		  '/test_rule_5/'
		 ]
       },
       # next series of three shows that interceding events don't matter
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/bar.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		 ]
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/something_else.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		 ]
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/foo.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_4/',
		  '/var year = 2006/',
		  '/test_rule_5/'
		 ]
       },
      ];

    $test_count += test_event_plan($before_test_plan);

    my $and_test_plan =
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and1.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and2.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_and/',
		 ]
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and2.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and2.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and1.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_and/',
		  ]
       },
      ];

    $test_count += test_event_plan($and_test_plan);

    my $or_test_plan =
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/or1.html",
	'type' => 'text/javascript',
'like' => ['/test_rule_or/',
		   '/var num = 1/',
		  ],
	'unlike' => ['/var num = 2/',
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/or2.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_or/',
		   '/var num = 2/',
		  ],
	'unlike' => ['/var num = 1/',
		  ],
       },
      ];

    $test_count += test_event_plan($or_test_plan);

    my $then_test_plan =
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/then1.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ['/var two = 2/',
		     '/var one = 1/',
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/then2.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_then/',
		   '/var two = 2/',
		   '/var one = 1/',
		  ],
       'diag' => 0
       },
       # next series of three shows that an interceding event cancels then1
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/then1.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ['/var two = 2/',
		     '/var one = 1/',
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/something_else.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ['/var two = 2/',
		     '/var one = 1/',
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/then2.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/'],
	'unlike' => ['/test_rule_then/',
		   '/var two = 2/',
		   '/var one = 1/',
		  ],
	'diag' => 0

       },
      ];

    $test_count += test_event_plan($then_test_plan);

    my $between_test_plan =
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/first.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/mid.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/last.html",
	'type' => 'text/javascript',
	'like' => ["/test_rule_between/",
		   "/var a = 't'/",
		   "/var b = 'd'/",
		   "/var c = 't'/",
		  ],
       },
       # without intervening 'mid' event, should not fire
      {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/first.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/last.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
      ];

    $test_count += test_event_plan($between_test_plan);


    my $not_between_test_plan =
       # with intervening 'mid' event, should not fire
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/firstn.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/midn.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       # without intervening 'mid' event, should  fire
      {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/firstn.html",
	'type' => 'text/javascript',
	'like' => ['/^\/\/ KNS \w\w\w \w\w\w\s+\d+ \d\d:\d\d:\d\d \d\d\d\d/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/lastn.html",
	'type' => 'text/javascript',
	'like' => ["/test_rule_notbetween/",
		   "/var a = 't'/",
		   "/var c = 't'/",
		  ],
	'diag' => 0,
       },
      ];

    $test_count += test_event_plan($not_between_test_plan);

    my $multi_test_plan =
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.google.com/search",
	'type' => 'text/javascript',
	'like' => ['/test_rule_google_1/',
		   '/test_rule_google_2/',
		   "/var search = 'search';/",
		  ],
	'diag' => 0,
       },
      ];

    $test_count += test_event_plan($multi_test_plan);


    my $email_test_plan =
      [{'url' => "$dn/mail/received/cs_test_1",
	'type' => 'text/javascript',
	'like' => ['/forward/',
		   '/pjw@kynetx.com/',
		   '/"msg_id":15/',
		  ],
	'unlike' => ['/"msg_id":25/',
		     '/"msg_id":35/',
		    ],
	'diag' => 0,
       },
       {'url' => $dn .'/mail/received/cs_test_1?from=swf@windley.com',
	'type' => 'text/javascript',
	'like' => ['/forward/',
		   '/"msg_id":25/',
		   '/"address":"swf"/',
		  ],
	'unlike' => ['/"msg_id":35/',
		  ],
	'diag' => 0,
       },
       {'url' => $dn .'/mail/received/cs_test_1?from=pjw@windley.org&to=swf@fulling.org&subj=Hey Phil you rock!',
	'type' => 'text/javascript',
	'like' => ['/forward/',
		   '/"name":"Phil"/',
		   '/"address":"pjw"/',
		   '/"msg_id":27/',
		  ],
	'unlike' => ['/"msg_id":35/',
		  ],
	'diag' => 0,
       },
       {'url' => "$dn/mail/sent/cs_test_1",
	'type' => 'text/javascript',
	'like' => ['/send/',
		   '/qwb@kynetx.com/',
		   '/"msg_id":35/',
		  ],
	'unlike' => ['/"msg_id":25/',
		   '/"msg_id":15/',
		  ],
	'diag' => 0,
       },
      ];

    $test_count += test_event_plan($email_test_plan);


    my $email_with_regexp_test_plan =
      [{'url' => $dn .'/mail/received/cs_test_1?from=swf@foobar.com',
	'type' => 'text/javascript',
	'like' => ['/forward/',
		   '/"msg_id":65/',
		   '/"address":"swf"/',
		  ],
	'unlike' => ['/"msg_id":35/',
		  ],
	'diag' => 0,
       },
      ];

    $test_count += test_event_plan($email_with_regexp_test_plan);


     my $submit_test_plan =
       [{'url' => "$dn/web/submit/cs_test_1?element=%23my_form&login=foo&cs_test_1:flop=goo",
 	'type' => 'text/javascript',
 	'like' => ["/var foobar = 4/",
 		   "/var foo = 'foo'/",
 		   "/var bar = 'goo'/",
 		   "/test_rule_submit/"
 		  ],
	'diag' => 0,
        },
       ];

     $test_count += test_event_plan($submit_test_plan);

     $submit_test_plan =
       [{'url' => "$dn/web/submit/cs_test_1?element=%23form_2&login=foo&cs_test_1:flop=goo",
 	'type' => 'text/javascript',
 	'like' => ["/var foobar = 4/",
 		   "/var foo = 'flop: goo'/",
 		   "/var foo = 'login: foo'/",
 		   "/test_rule_submit_2/"
 		  ],
	'diag' => 0,
        },
       ];

     $test_count += test_event_plan($submit_test_plan);


  }

$dp->stop_timer();
$logger->info("Events: ", $dp->get_metric("realtime"));

done_testing($test_count);

1;




