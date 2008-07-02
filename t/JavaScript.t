#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 7;
use Test::LongString;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::JavaScript qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


my $Simple_JS_Expr_Str = {
    'str' => 'absolute'
};

my $Simple_JS_Expr_Var = {
    'var' => 'city'
};

my $Complex_JS_Expr_1 = {
    'prim' => {
	'args' => [
	    {
		'str' => '/cgi-bin/weather.cgi?city='
	    },
	    {
		'prim' => {
		    'args' => [
			{
                            'var' => 'city'
			},
			{
                            'prim' => {
				'args' => [
				    {
					'str' => '&tc='
				    },
				    {
					'var' => 'tc'
				    }
				    ],
				'op' => '+'
                            }
			}
                        ],
		    'op' => '+'
		}
	    }
	    ],
	'op' => '+'
    }
};

my $Complex_JS_Expr_2 = {
    'prim' => {
	'args' => [
	    {
		'num' => 5
	    },
	    {
		'num' => 6
	    }
	    ],
	'op' => '+'
    }
};

my $Complex_JS_Expr_3 = {
    'prim' => {
	'args' => [
	    {
		'num' => 5
	    },
	    {
		'var' => 'temp'
	    }
	    ],
	'op' => '+'
    }
};


is(gen_js_expr($Simple_JS_Expr_Str), "'absolute'",
	  "Generating simple JS");

is(gen_js_expr($Complex_JS_Expr_1), "'/cgi-bin/weather.cgi?city=\' + city + '&tc=' + tc",
	  "Generating complex JS");


my $rule_name = 'foo';

my $rule_env = {$rule_name . ':city' => 'Blackfoot',
		$rule_name . ':tc' => '15'};

is(eval_js_expr($Simple_JS_Expr_Str, $rule_env, $rule_name), $Simple_JS_Expr_Str,
	  "Evaling simple JS with str");


is_deeply(eval_js_expr($Simple_JS_Expr_Var, $rule_env, $rule_name), 
   {'str' => 'Blackfoot'},
   "Evaling simple JS with var");

is_deeply(eval_js_expr($Complex_JS_Expr_1, $rule_env, $rule_name), 
          {'str' => '/cgi-bin/weather.cgi?city=Blackfoot&tc=15'},
	  "Evaling complex JS with strings");

is_deeply(eval_js_expr($Complex_JS_Expr_2, $rule_env, $rule_name), 
          {'num' => 11},
	  "Evaling complex JS with num");

$rule_env = {$rule_name . ':temp' => 20};
is_deeply(eval_js_expr($Complex_JS_Expr_3, $rule_env, $rule_name), 
          {'num' => 25},
	  "Evaling complex JS with num & var");



1;


