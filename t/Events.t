#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;

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

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();

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
$sm = compile_event_expr($ast->{'pagetype'}->{'event_expr'});

$initial = $sm->get_initial();
$n1 = $sm->next_state($initial, $ev);
ok($sm->is_final($n1), "ev leads to final state");
$test_count++;

#diag Dumper Kynetx::Rules::optimize_rule($ast);

#diag Dumper astToJson($ast);

#diag Kynetx::Events::process_event($r, 'web', 'pageview', ['cs_test_1']);


my $dn = "http://127.0.0.1/blue/event";

my $ruleset = 'cs_test_1';

my $mech = Test::WWW::Mechanize->new();

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
	diag $test->{'url'} if $test->{'diag'};
	if (defined $test->{'method'} && $test->{'method'} eq 'post') {
	  $mech->post_ok($test->{'url'}, $test->{'post_data'});
	} else {
	  $mech->get_ok($test->{'url'});
	}

	diag $mech->content() if $test->{'diag'};
	is($mech->content_type(), $test->{'type'});
	$tc += 2;
	foreach my $like (@{$test->{'like'}}) {
	  $mech->content_like($like);
	  $tc++;
	}
	foreach my $unlike (@{$test->{'unlike'}}) {
	  $mech->content_unlike($unlike);
	  $tc++;
	}
      }
      return $tc;
    }

    # tests in an event plan are order dependent since events are order dependent.  
    # Each plan is running different events in order to test a specific
    #   scenario defined in the rule's select statement

    my $before_test_plan = 
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/foo.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_4/',
		   '/var year = 2006/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/archives/2006/bar.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
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
	'like' => ['/^$/',
		 ]
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/something_else.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
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
	'like' => ['/^$/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and2.html",
	'type' => 'text/javascript',
	'like' => ['/test_rule_and/',
		 ]
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and2.html",
	'type' => 'text/javascript',
	'like' => ['/^$/']
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/and2.html",
	'type' => 'text/javascript',
	'like' => ['/^$/']
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
	'like' => ['/^$/',
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
       },
       # next series of three shows that an interceding event cancels then1
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/then1.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ['/var two = 2/',
		     '/var one = 1/',
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/something_else.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ['/var two = 2/',
		     '/var one = 1/',
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/then2.html",
	'type' => 'text/javascript',
	'like' => ['/^$/'],
	'unlike' => ['/test_rule_then/',
		   '/var two = 2/',
		   '/var one = 1/',
		  ],
       },
      ];

    $test_count += test_event_plan($then_test_plan);

    my $between_test_plan = 
      [{'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/first.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/mid.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
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
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/last.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
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
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/midn.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/lastn.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       # without intervening 'mid' event, should  fire
      {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/firstn.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var b = 'd'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/lastn.html",
	'type' => 'text/javascript',
	'like' => ["/test_rule_notbetween/",
		   "/var a = 't'/",
		   "/var b = 'd'/",
		   "/var c = 't'/",
		  ],
	'diag' => 0,
       },
       # does fire with some OTHER intervening enent
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/firstn.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
		  ],
	'unlike' => ["/var a = 't'/",
		     "/var c = 't'/",
		  ],
       },
       {'url' => "$dn/web/pageview/cs_test_1?caller=http://www.windley.com/something_else.html",
	'type' => 'text/javascript',
	'like' => ['/^$/',
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
       {'url' => "$dn/mail/sent/cs_test_1",
	'type' => 'text/javascript',
	'like' => ['/send/',
		   '/qwb@kynetx.com/',
		   '/"msg_id":35/',
		  ],
	'unlike' => ['/25/',
		   '/15/',
		  ],
       },
      ];

    $test_count += test_event_plan($email_test_plan);


#     my $submit_test_plan = 
#       [{'url' => "$dn/web/submit/cs_test_1",
# 	'method' => 'post',
# 	'post_data' => {'fname' => 'John', 'lname' => 'Doe'},
# 	'type' => 'text/javascript',
# 	'like' => ["/var form_data = {'fname': 'John', 'lname': 'Doe'}/",
# 		   "/submit_rule/"
# 		  ],
#        },
#       ];

#     $test_count += test_event_plan($submit_test_plan);


  }


done_testing($test_count);

1;


