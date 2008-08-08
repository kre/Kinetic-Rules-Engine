#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 39;
use Test::LongString;

use APR::URI qw/:all/;
use APR::Pool ();
use LWP::Simple;
use XML::XPath;


use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Predicates::Referers qw/:all/;
use Kynetx::Predicates::Markets qw/:all/;
use Kynetx::Predicates::Location qw/:all/;
use Kynetx::Predicates::Weather qw/:all/;
use Kynetx::Predicates::MediaMarkets qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);



#
# testing Javascript expression evaluation
# 

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


# 
# testing declarations and data sources
#

#sub gen_js_decl {
#   my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;

my %rule_env = ();
my %this_session = ();

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)
$BYU_req_info->{'referer'} = 'http://www.google.com/search?q=free+mobile+calls&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a'; 
$BYU_req_info->{'pool'} = APR::Pool->new;

$rule_name = 'foo';


sub mk_datasource_function {
    my ($source, $args, $diag) = @_;

    return sub {
	my $decl = {
	    'source' => $source,
	    'function' => shift,# passed in as argument
	    'lhs' => 'something',
	    'args' => $args,
	    'type' => 'data_source'
	};

	my $js_decl = Kynetx::JavaScript::gen_js_decl(
	    $BYU_req_info,
	    \%rule_env,
	    $rule_name,
	    \%this_session,
	    $decl
	    );
	
        diag($decl->{'function'} . " --> " . $js_decl) if $diag;
	return $js_decl;
    };

}


# check referer datasource

my $referer_function = mk_datasource_function('referer',[], 0);

is(&{$referer_function}('search_terms'), 
   'free+mobile+calls',
   'keywords from search engine referer' );



# check markets datasource
my $symbol = 'GOOG';
# http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG

my $market_function = mk_datasource_function('stocks', [{'str' => $symbol},], 0);

my $curr_qr = qr#\d+\.\d\d#;

is(&{$market_function}('symbol'), $symbol, "Returned symbol is the one we sent");
like(&{$market_function}('last'), $curr_qr, 'last price is a currency');
like(&{$market_function}('date'), qr#\d+/\d+/\d+#, "market date is a date");
like(&{$market_function}('time'), qr#\d+:\d#, "market time is a time");
like(&{$market_function}('change'), qr#[+|-]\d+\.\d+#, 'market change');
like(&{$market_function}('open'), $curr_qr, 'open price is a currency');
like(&{$market_function}('high'), $curr_qr, 'high price is a currency');
like(&{$market_function}('low'), $curr_qr, 'low price is a currency');
like(&{$market_function}('volume'), qr#\d+#, 'volume is string of digits');
like(&{$market_function}('previous_close'), $curr_qr, 'previous close price is a currency');
like(&{$market_function}('name'), qr#[A-Za-z ]+#, 'name is a string');



# check locations datasource

# http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG

my $location_function = mk_datasource_function('location', [], 0);


like(&{$location_function}('country_code'), qr#[A-Z]+#, 'country code');
like(&{$location_function}('country_code3'), qr#[A-Z]+#, 'country code3');
is(&{$location_function}('region'), 'UT', 'BYU is in Utah');
is(&{$location_function}('city'), 'Provo', 'BYU is in Provo');
is(&{$location_function}('postal_code'), '84602', 'BYU is in 84602');
like(&{$location_function}('latitude'), qr#[-]*\d+\.\d+#, 'latitude is a number');
like(&{$location_function}('longitude'), qr#[-]*\d+\.\d+#, 'longitude is a number');
is(&{$location_function}('dma_code'), '770', 'BYU is in DMA 770');
is(&{$location_function}('area_code'), '801', 'BYU is in area 801');


# check weather datasource

my $weather_function = mk_datasource_function('weather',[], 0);

my $temp_qr = qr#\d+\.*\d*#;  # what a temperature looks like
like(&{$weather_function}('curr_temp'), $temp_qr, 'curr_temp');
like(&{$weather_function}('curr_cond'), qr#\w#, 'curr_cond');
like(&{$weather_function}('curr_cond_code'), qr#\d#, 'curr_cond_code');
like(&{$weather_function}('tomorrow_low'), $temp_qr, 'tomorrow_low');
like(&{$weather_function}('tomorrow_high'), $temp_qr, 'tomorrow_high');
like(&{$weather_function}('tomorrow_cond'), qr#\w#, 'tomorrow_cond');
like(&{$weather_function}('tomorrow_cond_code'), qr#\d\d#, 'tomorrow_cond_code');


# check media market datasource

my $mm_function = mk_datasource_function('mediamarket',[], 0);

like(&{$mm_function}('dma'), qr#\d\d\d#, 'dma');
like(&{$mm_function}('rank'), qr#\d+#, 'rank');
like(&{$mm_function}('name'), qr#\w#, 'name');
like(&{$mm_function}('households'), qr#\d+#, 'households');



1;


