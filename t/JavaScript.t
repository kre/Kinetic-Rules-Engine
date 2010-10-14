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
use lib qw(../);
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

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;


use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Operators qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Modules qw/:all/;
use Kynetx::Predicates::Referers qw/:all/;
use Kynetx::Predicates::Markets qw/:all/;
use Kynetx::Predicates::Location qw/:all/;
use Kynetx::Predicates::Weather qw/:all/;
use Kynetx::Predicates::MediaMarkets qw/:all/;
use Kynetx::Predicates::Page qw/:all/;
use Kynetx::Session qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::FakeReq qw(:all);

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

my $logger = get_logger();

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;

use ExprTests qw/:all/;


my $r = Kynetx::Test::configure();

my $rid = 'abcd1234';
my $rule_name = 'foo';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid,
    {'ip' => '128.187.16.242', # Utah (BYU)
     'referer' => 'http://www.google.com/search?q=free+mobile+calls&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a',
     'caller' => 'http://www.windley.com/archives/2008/07?q=foo',
     'kvars' => '{"foo": 5, "bar": "fizz", "bizz": [1, 2, 3]}',
     'foozle' => 'Foo',
     "$rid:datasets" => "aaa,aaawa,ebates"
    }
   );

my $krl_src;

$krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json";
}
_KRL_

my $krl = Kynetx::Parser::parse_global_decls($krl_src);


my $rule_env = Kynetx::Test::gen_rule_env(
   {'datasource:'.$krl->[0]->{'name'} => $krl->[0],
   });

my $session = Kynetx::Test::gen_session($r, $rid);



my $test_count = 0;


#---------------------------------------------------------------------------------
# Expressions
#---------------------------------------------------------------------------------


my $testcases = t::ExprTests::get_expr_testcases($rule_env);

# diag Dumper $testcases;
diag "Safe to ignore deep recursion warnings";

foreach my $case (@{ $testcases } ) {

#  diag $test_count;
#  $case->{'diag'} = 1;

  diag(Dumper($case->{'expr'})) if $case->{'diag'};

  my ($e, $val, $js, $lhs) = '';

  if ($case->{'type'} eq 'expr') {

    $val = Kynetx::Parser::parse_expr($case->{'krl'});

    diag("AST = ", Dumper($val)) if $case->{'diag'};

    $js = gen_js_expr($val);

  } elsif ($case->{'type'} eq 'pre') {

    $val = Kynetx::Parser::parse_pre($case->{'krl'});
    ($js,$e) = Kynetx::Expressions::eval_prelude($my_req_info,
						 $rule_env,
						 $rule_name,
						 $session,
						 $val) ;

  } elsif ($case->{'type'} eq 'decl') {
    $val = Kynetx::Parser::parse_decl($case->{'krl'});

    diag("AST = ", Dumper($val)) if $case->{'diag'};

    $js = Kynetx::Expressions::eval_one_decl($my_req_info,
					     $rule_env,
					     $rule_name,
					     $session,
					     $val) ;
  }

  diag("JS = $js") if $case->{'diag'};

  unless ($case->{'expected_js'} eq '_ignore_') {
    is_string_nows($js,
		   $case->{'expected_js'},
		   "KRL: " . $case->{'krl'});


    $test_count++;
  }

}




#--------------------------------------------------------------------------------
# string functions
#--------------------------------------------------------------------------------
my $no_escape = "foo bar is a boo bar";
my $pls_escape = "foo bar isn't a boo bar";
my $escaped = "foo bar isn\\'t a boo bar";
is(escape_js_str($no_escape), $no_escape, "Escape a string");
is(escape_js_str($pls_escape), $escaped, "Escape a string");
$test_count += 2;

my $nl_escape = "foo
bar
foo";
$escaped = 'foo\nbar\nfoo';
#diag $nl_escape;
#diag escape_js_str($nl_escape);
is(escape_js_str($nl_escape), $escaped, "Escape newlines in s string");
$test_count++;


#--------------------------------------------------------------------------------
# gen_js_var
#--------------------------------------------------------------------------------

is(gen_js_var("c","3"), "var c = 3;\n", "simple stings");
$test_count += 1;


my $test_hash = {"a" => 5,
		 "b" => undef,
		 "c" => {"c1" => 3,
			 "c2" => "hello"}};


my $denval = Kynetx::Expressions::exp_to_den($test_hash);

my $jsval = Kynetx::JavaScript::gen_js_expr($denval);

# we generate JS with ' and Json expects "
$jsval =~ s/'/"/g;
my $new_hash = Kynetx::Json::jsonToAst($jsval);

is_deeply($new_hash, $test_hash, "Round trip through exp_to_den and gen_js_expr");
$test_count += 1;



session_delete($rid, $session, 'my_count');
session_delete($rid, $session, 'my_trail');
session_delete($rid, $session, 'my_flag');

session_cleanup($session);



done_testing($test_count);





1;


