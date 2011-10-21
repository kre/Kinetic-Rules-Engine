#!/usr/bin/perl -w

# Working file for new expressions that has less overhead than the ExprTests.pm/Expressions.t
# test harness

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
my $krl_src;
my $rid = 'abcd1234';
my $rule_name = 'foo';
my $test_count=0;
my $session = Kynetx::Test::gen_session($r, $rid);

my $my_req_info = Kynetx::Test::gen_req_info($rid,
    {#'ip' => '128.187.16.242', # Utah (BYU)
     'referer' => 'http://www.google.com/search?q=free+mobile+calls&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a',
     'caller' => 'http://www.windley.com/archives/2008/07?q=foo',
     'kvars' => '{"foo": 5, "bar": "fizz", "bizz": [1, 2, 3]}',
     'foozle' => 'Foo',
     "$rid:datasets" => "aaa,aaawa,ebates"
    }
   );

my @expr_testcases;


sub add_expr_testcase {
      my($krl,$type,$js,$expected,$diag) = @_;

      push(@expr_testcases, {'krl' => $krl,
			     'type' => $type,
			     'expected_js' => $js,
			     'expected_val' => $expected,
			     'diag' => $diag,
			    });
    }

my $rule_env = Kynetx::Test::gen_rule_env();
$rule_env = extend_rule_env("myHash",{
	'a' => '1.1',
	'b' => {
		'c' => '2.1',
		'e' => '2.2',
		'f' => {
			'g' => ['3.a','3.b','3.c','3.d'],
			'h' => 5
		}
	},
	'd' =>'1.3'	
},$rule_env);

$rule_env = extend_rule_env("g","a",$rule_env);


################# Insert tests here
$krl_src = <<_KRL_;
[5, -1, temp]
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "[5, -1, temp]",
     mk_expr_node('array', [mk_expr_node('num', 5),
 			    mk_expr_node('num', -1),
 			    mk_expr_node('num', 20)]),
    0);

my $re_ = superhashof({
	'some_numbers' => [1, 0, -1, 1.2, 1.0001 ]
});
$krl_src = <<_KRL_;
pre {
	some_numbers = [1, 0, -1, 1.2, 1.0001];
}
_KRL_
add_expr_testcase(
    $krl_src,
    'pre',
    "[1, 0, -1, 1.2, 1.0001]",
     $re_,
    0);


################### Above this line
ENDY:

foreach my $case (@expr_testcases ) {
	diag("KRL = ", Dumper($case->{'krl'})) if $case->{'diag'};
	my ($e,$val,$js);
	if ($case->{'type'} eq 'expr') {
    	$val = Kynetx::Parser::parse_expr($case->{'krl'});
    	diag("AST = ", Dumper($val)) if $case->{'diag'};
	    $e = eval_expr($val,
			   $rule_env,
			   $rule_name,
			   $my_req_info,
			   $session);
	} elsif ($case->{'type'} eq 'pre') {
    	$val = Kynetx::Parser::parse_pre($case->{'krl'});
    	($js,$e) = Kynetx::Expressions::eval_prelude($my_req_info,
						 $rule_env,
						 $rule_name,
						 $session,
						 $val) ;
		diag("JS = $js") if $case->{'diag'};
  	}
  	
	diag("Expr = ", Dumper($e)) if $case->{'diag'};
	my $result = cmp_deeply($e,
		    $case->{'expected_val'},
		    "Evaling " . $case->{'krl'});
	die unless $result;
	$test_count++;
	
}

session_cleanup($session);


done_testing($test_count);


1;


