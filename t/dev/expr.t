#!/usr/bin/perl -w

use lib qw(/web/lib/perl /web/lib/perl/t);
use strict;

no warnings 'recursion';

use Test::More;
use Test::LongString;
use Test::Deep;

use APR::URI qw/:all/;
use APR::Pool ();
use LWP::Simple;
use XML::XPath;
use LWP::UserAgent;
use JSON::XS;
use Cache::Memcached;
use Apache::Session::Memcached;
use DateTime;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

my $logger = get_logger();

use Kynetx::Test qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Parser qw/:all/;


use Kynetx::FakeReq qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;

use ExprTests qw/:all/;


my $r = Kynetx::Test::configure();

my $rid = 'abcd1234';
my $rule_name = 'foo';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid,
    {#'ip' => '128.187.16.242', # Utah (BYU)
     'referer' => 'http://www.google.com/search?q=free+mobile+calls&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a',
     'caller' => 'http://www.windley.com/archives/2008/07?q=foo',
     'kvars' => '{"foo": 5, "bar": "fizz", "bizz": [1, 2, 3]}',
     'foozle' => 'Foo',
     "$rid:datasets" => "aaa,aaawa,ebates"
    }
   );

my $krl_src;

my $init_rule_env = Kynetx::Test::gen_rule_env(
   {'city2' => 'Seattle',
   });

my $rule_env = extend_rule_env({
    'foo' =>     mk_expr_node('closure', {'vars' => ['x'],
			     'decls' => [{'rhs' => {
						    'args' => [
							       {
								'val' => 'x',
								'type' => 'var'
							       },
							       {
								'val' => 3,
								'type' => 'num'
							       }
							      ],
						    'type' => 'prim',
						    'op' => '+'
						   },
					  'lhs' => 'y',
					  'type' => 'expr'
					 }
					],
			     'sig' => 'thisisafakesig',
			     'expr' => {'args' => [
						   {
						    'val' => 'y',
						    'type' => 'var'
						   },
						   {
						    'val' => 5,
						    'type' => 'num'
						   }
						  ],
					'type' => 'ineq',
					'op' => '<'
				       },
			     'env' => $init_rule_env
			    }
		 ),

   }, $init_rule_env);

my $session = Kynetx::Test::gen_session($r, $rid);
session_set($rid, $session, 'my_flag');



my $test_count = 0;

my $url_timeout = 1;


#---------------------------------------------------------------------------------
# Expressions
#---------------------------------------------------------------------------------


my $testcases = t::ExprTests::get_expr_testcases($rule_env);

# diag Dumper $testcases;

diag "Safe to ignore deep recursion warnings";

foreach my $case (@{ $testcases } ) {

#  diag $test_count;
  $case->{'diag'} = 1;

  $logger->debug("Trying expression: ", sub {Dumper($case->{'krl'})});

  my ($e, $val, $js, $lhs) = '';

  if ($case->{'type'} eq 'expr') {

    $val = Kynetx::Parser::parse_expr($case->{'krl'});

    diag("AST = ", Dumper($val)) if $case->{'diag'};

    $e = eval_expr($val,
		   $rule_env,
		   $rule_name,
		   $my_req_info,
		   $session);

  }
  diag("Expr = ", Dumper($e)) if $case->{'diag'};

  my $good = cmp_deeply($e,
	    $case->{'expected_val'},
	    "Evaling " . $case->{'krl'});

	    die unless ($good);

  $test_count++;

}


session_delete($rid, $session, 'my_count');
session_delete($rid, $session, 'my_trail');
session_delete($rid, $session, 'my_flag');

session_cleanup($session);


done_testing($test_count);


1;


