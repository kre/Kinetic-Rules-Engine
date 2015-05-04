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
use lib qw(/web/lib/perl /web/lib/perl/t);
use strict;

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
#Log::Log4perl->easy_init($DEBUG);
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
    }
   );

Kynetx::Request::add_event_attr($my_req_info,  "$rid:datasets", "aaa,aaawa,ebates");


my $krl_src;

$krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json";
}
_KRL_

my $krl = Kynetx::Parser::parse_global_decls($krl_src);

$logger->debug("global dec",sub {Dumper($krl)});


my $init_rule_env = Kynetx::Test::gen_rule_env(
   {'datasource:'.$krl->[0]->{'name'} => $krl->[0],
    'city2' => 'Seattle',
    'string1' => "aab",
    'string2' => "abb",
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
	

$rule_env->{'ruleset_name'} = $rid;

my $session = Kynetx::Test::gen_session($r, $rid);
session_set($rid, $session, 'my_flag');



my $test_count = 0;

my $url_timeout = 1;


#
# testing declarations and data sources
#

#sub gen_js_decl {
#   my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;


#diag "----------------------------------------------------------";

sub eval_str_test {
  my ($str) = @_; 
#  diag "Orig str: ", Dumper $str;
  my $parsed_str = Kynetx::Parser::parse_decl($str)->{'rhs'};
#  diag "Parsed str: ", Dumper $parsed_str;
  return Kynetx::Expressions::eval_str(
       $parsed_str,
       $rule_env,
       $rule_name,
       $my_req_info,
       $session)->{'val'};
}

$krl_src = <<_KRL_;
x = "My city is #{city} Idaho"
_KRL_
is(eval_str_test($krl_src), "My city is Blackfoot Idaho", $krl_src);
$test_count++;

$krl_src = <<_KRL_;
x = "My city is #{city}"
_KRL_
is(eval_str_test($krl_src), "My city is Blackfoot", $krl_src);
$test_count++;

$krl_src = <<_KRL_;
x = "#{city} is my city"
_KRL_
is(eval_str_test($krl_src), "Blackfoot is my city", $krl_src);
$test_count++;

$krl_src = <<_KRL_;
x = "#{city} is my city and #{city2} is not"
_KRL_
is(eval_str_test($krl_src), "Blackfoot is my city and Seattle is not", $krl_src);
$test_count++;

$krl_src = <<_KRL_;
x = "#{city + city2} is my city"
_KRL_
is(eval_str_test($krl_src), "BlackfootSeattle is my city", $krl_src);
$test_count++;

$krl_src = <<_KRL_;
x = <<#{b + store.pick("\$..book[1].price")} is the price>>
_KRL_
is(eval_str_test($krl_src), "23.99 is the price", $krl_src);
$test_count++;

$krl_src = <<_KRL_;
x = <<#{b + store.pick("\$..book[1].price")} is the price in #{city2}>>
_KRL_
is(eval_str_test($krl_src), "23.99 is the price in Seattle", $krl_src);
$test_count++;




sub mk_datasource_function {
    my ($source, $args, $diag) = @_;

    return sub {

	my $function = shift; # name to test

	my $decl_src = <<_KRL_;
something = $source:$function($args);
_KRL_

	diag $decl_src if $diag;
        my $decl = Kynetx::Parser::parse_decl($decl_src);

	diag(Dumper($decl)) if $diag;
	my ($v,$js_decl) = Kynetx::Expressions::eval_decl(
	    $my_req_info,
	    $rule_env,
	    $rule_name,
	    $session,
	    $decl
	    );

	my $result = $js_decl;

        diag($decl->{'rhs'}->{'predicate'} . " --> " . $result) if $diag;
	return $result;
    };

}


# check referer datasource

my $referer_function = mk_datasource_function('referer','', 0);

is(&{$referer_function}('search_terms'),
   'free+mobile+calls',
   'keywords from search engine referer' );
$test_count++;

# check markets datasource
# http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG

SKIP: {
    my $ua = LWP::UserAgent->new('timeout' => $url_timeout);

    my $check_url = "http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG";
#    my $check_url = "http://foo";

    diag "Checking $check_url";
    my $response = $ua->get($check_url);
#    diag $response->content;
    my $server_unavailable =  (! $response->is_success || $response->content =~ /Bad hostname/ || $response->content =~ /too busy/);

    my $num_tests = 11;
    $test_count += $num_tests;
    if ($server_unavailable) {
      skip "No server available", $num_tests;
    }

    my $symbol = 'GOOG';

# $symbol has to be a string that is itself a valid KRL string
    my $market_function = mk_datasource_function('stocks', '"'.$symbol.'"' , 0);

    my $curr_qr = qr#\d+\.\d\d|N/A#;

    is(&{$market_function}('symbol'), $symbol , "Returned symbol is the one we sent");


    like(&{$market_function}('last'), $curr_qr, 'last price is a currency');
    like(&{$market_function}('date'), qr#\d+/\d+/\d+#, "market date is a date");
    like(&{$market_function}('time'), qr#\d+:\d#, "market time is a time");
    like(&{$market_function}('change'), qr#[+|-]?\d+\.\d+#, 'market change');
    like(&{$market_function}('open'), $curr_qr, 'open price is a currency');
    like(&{$market_function}('high'), $curr_qr, 'high price is a currency');
    like(&{$market_function}('low'), $curr_qr, 'low price is a currency');
    like(&{$market_function}('volume'), qr#\d+#, 'volume is string of digits');
    like(&{$market_function}('previous_close'), $curr_qr, 'previous close price is a currency');
    like(&{$market_function}('name'), qr#[A-Za-z ]+#, 'name is a string');

}


# check locations datasource

# http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG


my $location_function = mk_datasource_function('location', '', 0);



like(&{$location_function}('country_code'), qr#[A-Z]+#, 'country code');
like(&{$location_function}('country_code3'), qr#[A-Z]+#, 'country code3');
is(&{$location_function}('region'), 'WA', 'Amazon is in WA');
is(&{$location_function}('city'), 'Seattle', 'Amazon is in Seattle');
is(&{$location_function}('postal_code'), '98104', 'Amazon is in 98104');
like(&{$location_function}('latitude'), qr#[-]*\d+\.\d+#, 'latitude is a number');
like(&{$location_function}('longitude'), qr#[-]*\d+\.\d+#, 'longitude is a number');
is(&{$location_function}('dma_code'), '819', 'Amazon is in DMA 819');
is(&{$location_function}('area_code'), '206', 'Amazon is in area 206');
$test_count += 9;

# check weather datasource

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = 'http://xml.weather.yahoo.com/forecastrss?p=84043&u=f';

    diag "Checking $check_url";
    my $response = $ua->get($check_url);
#    diag $response->content;

    my $num_tests = 7;
    $test_count += $num_tests;
    skip "No server available", $num_tests if (! $response->is_success || $response->content =~ /Bad hostname/);


    my $weather_function = mk_datasource_function('weather','', 0);

    my $temp_qr = qr#\d+\.*\d*#;  # what a temperature looks like
    like(&{$weather_function}('curr_temp'), $temp_qr, 'curr_temp');
    like(&{$weather_function}('curr_cond'), qr#\w#, 'curr_cond');
    like(&{$weather_function}('curr_cond_code'), qr#\d#, 'curr_cond_code');
    like(&{$weather_function}('tomorrow_low'), $temp_qr, 'tomorrow_low');
    like(&{$weather_function}('tomorrow_high'), $temp_qr, 'tomorrow_high');
    like(&{$weather_function}('tomorrow_cond'), qr#\w#, 'tomorrow_cond');
    like(&{$weather_function}('tomorrow_cond_code'), qr#\d+#, 'tomorrow_cond_code');

  }


my $math_function = mk_datasource_function('math', 9, 0);
like(&{$math_function}('random'), qr#^\d$#, 'one digit random number');
$test_count++;

# check user defined data sources
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "http://search.twitter.com/search.json?q=apple";

    diag "Checking $check_url";
    my $response = $ua->get($check_url);
#    diag $response->content;
    my $num_tests = 1;
    $test_count += $num_tests;
    skip "No server available", $num_tests if (! $response->is_success  || $response->content =~ /Bad hostname/);

    my $ds_function = mk_datasource_function('datasource','"?q=rootbeer"', 0);
    $logger->debug("Got $ds_function");
    contains_string(encode_json(&{$ds_function}('twitter_search')),
		    '{"since_id_str":"0","page":1',
		    'user defined datasource');

}

is(infer_type('hello'),'str','inferring simple string');
is(infer_type('5'),'num','inferring single digit number number');
is(infer_type('0'),'num','inferring 0 as a number number');
is(infer_type('15'),'num','inferring integer as number');
is(infer_type('0.4'),'num','inferring real number');
is(infer_type('0847564'),'str','inferring number with leading 0');
is(infer_type('true'),'bool','inferring boolean');
is(infer_type('false'),'bool','inferring boolean');
is(infer_type([0,1,2]),'array','inferring array');
is(infer_type({'a' => 0}),'hash','inferring hash');
$test_count += 10;




##
## var_free_in_expr
##
sub check_free {
   my($var, $expr, $etype, $diag) = @_;

   diag "------------------------ var_free_in_expr() ----------------------" if $diag;

   my $ptree = Kynetx::Parser::parse_decl($expr);

   if ($ptree->{'type'} eq 'expr') {
     # only care about rhs of non-here_doc decls
     $ptree = $ptree->{'rhs'};
   }

  diag Dumper $ptree if $diag;

  $test_count++;
   ok(var_free_in_expr($var, $ptree), $var . " occurs free in "  . $etype);
 }

sub check_not_free {
   my($var, $expr, $etype, $diag) = @_;

   my $ptree = Kynetx::Parser::parse_decl($expr);

   if ($ptree->{'type'} eq 'expr') {
     # only care about rhs of non-here_doc decls
     $ptree = $ptree->{'rhs'};
   }

   diag Dumper $ptree if $diag;

   $test_count++;
   ok(!var_free_in_expr($var, $ptree), $var . " does not occur free in " . $etype);
 }

check_free("v", "q = v + 3", "prim");
check_not_free("x", "q = v + 3", "prim");

check_not_free("v", "q = true", "bool");
check_not_free("v", "q = false", "bool");
check_not_free("v", "q = 1", "num");
check_not_free("v", "q = 10 + 20", "prim");
check_not_free("v", 'q = "purple"', "string");
check_not_free("v", 'q = re/x*/', "regexp");

check_free("v", "q = v + x", "prim");
check_free("v", "q = x + v", "prim");
check_not_free("v", "q = y + x", "prim");
check_not_free("v", 'q = ["a", "b", "v"]', "string array");
check_free("v", 'q = [a, b, v]', "var array");
check_not_free("v", 'q = [a, b, c]', "var array");

check_free("v", 'q = v.pick("$..[0]")', "operator");
check_not_free("v", 'q = x.pick("$..[0]")', "operator");

check_free("v", 'q = x.pick("$..[0]" + v)', "operator");


check_free("v", 'q = today(v)', "predicate");

check_free("v", 'q = weather:sunny(v)', "qualified predicate");
check_free("v", 'q = (v) => 3 | x', "conditional test");
check_free("v", 'q = (r) => v | 3', "conditional then");
check_free("v", 'q = (s) => 3 | v', "conditional else");

check_free("math:random()", 'q = math:random()', "math:random", 0);

my $k = <<EOF;
x = <<
  This is a test #{v} of something
 >>
EOF

check_free("v", $k, "bee stings");
check_not_free("v", 'x = << This is a test #{y} of something >>', "different bee sting");


#
# cachable
#
sub check_cachable {
   my($sense, $expr, $etype) = @_;

   my $ptree = Kynetx::Parser::parse_decl($expr);

#   diag Dumper $ptree;

   $test_count++;
   if ($sense eq 'is') {
     ok(Kynetx::Expressions::cachable_decl($ptree),  $etype . " is cachable " );
   } else {
     ok(!Kynetx::Expressions::cachable_decl($ptree),  $etype . " is not cachable " );
     
   }
 }


check_cachable('is', 'f = function(x){ 5 }', 'function');
check_cachable('is not', 'x = ent:x', 'entity');


##
## exp_to_den
##

sub test_exp_to_den {
  my($ds, $desc, $diag) = @_;

  my $new_ds = Kynetx::Expressions::exp_to_den($ds);

  diag Dumper $new_ds if $diag;

  my $rebuilt_ds = Kynetx::Expressions::den_to_exp($new_ds);

  diag $rebuilt_ds if $diag;

  $test_count++;
  is_deeply($ds, $rebuilt_ds, $desc);
}

test_exp_to_den(
  'hello',
  "Simple string",
  0
);

test_exp_to_den(
  5,
  "Number",
  0
);

test_exp_to_den(
  5.87,
  "Decimal number",
  0
);

test_exp_to_den(
  [1,2,3],
  "array",
  0
);

test_exp_to_den(
  {'x' => 5,
   'y' => 'hello'},
  "simple hash",
  0
);

test_exp_to_den(
  {'x' => 5,
   'y' => 'hello',
   'z' => [1, 4, 5]
  },
  "hash with array",
  0
);

test_exp_to_den(
  [{'x' => 5,
    'y' => 'hello',
   },
   {'r' => 'another',
    'x' => [1, 5, 6]
   }
  ],
  "Array of hashes with array",
  0
);



my $twitter_json = '[{"favorited":false,"geo":"","in_reply_to_user_id":"","in_reply_to_status_id":"","in_reply_to_screen_name":"","source":"<a href=\"http://foursquare.com\" rel=\"nofollow\">foursquare</a>","user":{"description":"I build things; I write code; I void warranties","statuses_count":5983,"profile_sidebar_fill_color":"e0ff92","followers_count":1974,"geo_enabled":false,"time_zone":"Mountain Time (US & Canada)","profile_sidebar_border_color":"87bc44","following":true,"favourites_count":10,"verified":false,"notifications":false,"profile_text_color":"000000","profile_background_image_url":"http://a3.twimg.com/profile_background_images/3343255/blue-water-drops.jpg","protected":false,"url":"http://www.windley.com","friends_count":581,"profile_link_color":"0000ff","profile_image_url":"http://a3.twimg.com/profile_images/525686087/windley_2009_145_normal.jpg","location":"Utah","name":"Phil Windley","profile_background_tile":false,"id":1878461,"utc_offset":-25200,"created_at":"Thu Mar 22 14:04:00 +0000 2007","profile_background_color":"001E4C","screen_name":"windley"},"truncated":false,"id":6576388596,"text":"Friday lunch!  Stop by sometime. (@ Kynetx World Headquarters in Lehi) http://4sq.com/3TSQhf","created_at":"Fri Dec 11 19:35:09 +0000 2009"}]';


test_exp_to_den(
  jsonToAst($twitter_json),
  "Complex twitter JSON",
  0
);

#---------------------------------------------------

# ---------------booily -------------------------
is(Kynetx::Expressions::boolify(1), JSON::XS::true, "boolify for 1");
$test_count++;

is(Kynetx::Expressions::boolify(0), JSON::XS::false, "boolify for 0");
$test_count++;

is(Kynetx::Expressions::boolify(10), 10, "boolify for 10");
$test_count++;

is(Kynetx::Expressions::boolify(""), "", "boolify for empty string");
$test_count++;

is(Kynetx::Expressions::boolify("flipper"), "flipper", "boolify for string");
$test_count++;


#diag "----------------------------------------------------------";


#---------------------------------------------------------------------------------
# Expressions
#---------------------------------------------------------------------------------


my $testcases = t::ExprTests::get_expr_testcases($rule_env);

# diag Dumper $testcases;

diag "Safe to ignore deep recursion warnings";

foreach my $case (@{ $testcases } ) {

#  diag $test_count;
#  $case->{'diag'} = 1;

  diag("KRL = ", Dumper($case->{'krl'})) if $case->{'diag'};

  my ($e, $val, $js, $lhs) = '';

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

  } elsif ($case->{'type'} eq 'decl') {
    $val = Kynetx::Parser::parse_decl($case->{'krl'});

    diag("AST = ", Dumper($val)) if $case->{'diag'};

    ($lhs,$e) = Kynetx::Expressions::eval_decl($my_req_info,
					       $rule_env,
					       $rule_name,
					       $session,
					       $val) ;
  }

  diag("Expr = ", Dumper($e)) if $case->{'diag'};

  my $result = cmp_deeply($e,
	    $case->{'expected_val'},
	    "Evaling " . $case->{'krl'});
  if (! $result ){
  	diag("RE: ", Dumper($rule_env));
  	die;
  };
  
  $test_count++;

}


session_delete($rid, $session, 'my_count');
session_delete($rid, $session, 'my_trail');
session_delete($rid, $session, 'my_flag');

session_cleanup($session);


done_testing($test_count);


1;


