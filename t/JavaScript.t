#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI qw/:all/;
use APR::Pool ();
use LWP::Simple;
use XML::XPath;
use LWP::UserAgent;
use JSON::XS;

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Operators qw/:all/;
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



my (@expr_testcases, @decl_testcases, $str, $val, $krl);

sub add_expr_testcase {
    my($str,$js,$expected,$diag) = @_;
    my $val = Kynetx::Parser::parse_expr($str);

    chomp $str;
    
    diag("$str = ", Dumper($val)) if $diag;

    push(@expr_testcases, {'expr' => $val,
		       'src' => $str,
		       'js' => $js,
		       'val' => $expected eq 'unchanged' ? $val : $expected});
}

sub add_decl_testcase {
    my($str, $expected, $diag) = @_;
    my $val = Kynetx::Parser::parse_decl($str);

    chomp $str;
    
    diag("$str = ", Dumper($val)) if $diag;

    push(@decl_testcases, {'expr' => $val,
			   'src' => $str,
			   'val' => $expected,
	 });
}

my $krl_src;

$krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json";
}
_KRL_
$krl = Kynetx::Parser::parse_global_decls($krl_src);
    
my $rule_name = 'foo';

my $rule_env = {$rule_name . ':city' => 'Blackfoot',
		$rule_name . ':tc' => '15',
		$rule_name . ':temp' => 20,
		$rule_name . ':booltrue' => 'true',
		$rule_name . ':boolfalse' => 'false',
		$rule_name . ':a' => '10',
		$rule_name . ':b' => '11',
		'datasource:'.$krl->[0]->{'name'} => $krl->[0]
               };


$rule_env->{$rule_name .':store'} = {
	"store"=> {
		"book"=> [ 
			{
				"category"=> "reference",
				"author"=> "Nigel Rees",
				"title"=> "Sayings of the Century",
				"price"=> 8.95,
				"ratings"=> [
					1,
					3,
					2,
					10
				]
			},
			{ 
				"category"=> "fiction",
				"author"=> "Evelyn Waugh",
				"title"=> "Sword of Honour",
				"price"=> 12.99,
				"ratings" => [
						"good",
						"bad",
						"lovely"
					]
			},
			{
				"category"=> "fiction",
				"author"=> "Herman Melville",
				"title"=> "Moby Dick",
				"isbn"=> "0-553-21311-3",
				"price"=> 8.99
			},
			{
				"category"=> "fiction",
				"author"=> "J. R. R. Tolkien",
				"title"=> "The Lord of the Rings",
				"isbn"=> "0-395-19395-8",
				"price"=> 22.99
			}
		],
		"bicycle"=> {
			"color"=> "red",
			"price"=> 19.95
		}
	}
};




my $this_session = {};

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)
$BYU_req_info->{'referer'} = 'http://www.google.com/search?q=free+mobile+calls&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a'; 
$BYU_req_info->{'pool'} = APR::Pool->new;
$BYU_req_info->{'kvars'} = '{"foo": 5, "bar": "fizz", "bizz": [1, 2, 3]}';
$BYU_req_info->{'foozle'} = 'Foo';



$str = <<_KRL_;
"absolute"
_KRL_
add_expr_testcase(
    $str,
    "'absolute'",
    mk_expr_node('str', 'absolute'));

$str = <<_KRL_;
city
_KRL_
add_expr_testcase(
    $str,
    'city',
    mk_expr_node('str', 'Blackfoot')
    );

$str = <<_KRL_;
true
_KRL_
add_expr_testcase(
    $str,
    'true',
    mk_expr_node('bool', 'true')
    );

$str = <<_KRL_;
false
_KRL_
add_expr_testcase(
    $str,
    'false',
    mk_expr_node('bool', 'false')
    );

$str = <<_KRL_;
1022
_KRL_
add_expr_testcase(
    $str,
    1022,
    mk_expr_node('num', 1022)
    );


$str = <<_KRL_;
5 + 6
_KRL_
add_expr_testcase(
    $str,
    '(5 + 6)',
    mk_expr_node('num', 11),
    0);

$str = <<_KRL_;
6 - 5
_KRL_
add_expr_testcase(
    $str,
    '(6 - 5)',
    mk_expr_node('num', 1));

$str = <<_KRL_;
5 * 7
_KRL_
add_expr_testcase(
    $str,
    '(5 * 7)',
    mk_expr_node('num', 35),
    0);

$str = <<_KRL_;
25 / 5
_KRL_
add_expr_testcase(
    $str,
    '(25 / 5)',
    mk_expr_node('num', 5));

$str = <<_KRL_;
-5
_KRL_
add_expr_testcase(
    $str,
    '-5',
    mk_expr_node('num', -5),
    0);

$str = <<_KRL_;
"foo" + "bar"
_KRL_
add_expr_testcase(
    $str,
    "('foo' + 'bar')",
    mk_expr_node('str', 'foobar'),
    0);


$str = <<_KRL_;
"/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc
_KRL_
add_expr_testcase(
    $str,
    "('/cgi-bin/weather.cgi?city=' + (city + ('&tc=' + tc)))",
    mk_expr_node('str', '/cgi-bin/weather.cgi?city=Blackfoot&tc=15'),
    0);

$str = <<_KRL_;
"/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc + "foo=" + city + "fizz=" + tc
_KRL_
add_expr_testcase(
    $str,
    "('/cgi-bin/weather.cgi?city=' + (city + ('&tc=' + (tc + ('foo=' + (city + ('fizz=' + tc)))))))",
    mk_expr_node('str', '/cgi-bin/weather.cgi?city=Blackfoot&tc=15foo=Blackfootfizz=15'),
    0);




$str = <<_KRL_;
5 + temp
_KRL_
add_expr_testcase(
    $str,
    "(5 + temp)",
    mk_expr_node('num', 25),
    0);

$str = <<_KRL_;
(5 + 6) * 3
_KRL_
add_expr_testcase(
    $str,
    "((5 + 6) * 3)",
    mk_expr_node('num', 33),
    0);

$str = <<_KRL_;
5 + 6 * 3
_KRL_
add_expr_testcase(
    $str,
    "(5 + (6 * 3))",
    mk_expr_node('num', 23),
    0);

$str = <<_KRL_;
[5, 6, 7]
_KRL_
add_expr_testcase(
    $str,
    "[5, 6, 7]",
     mk_expr_node('array', [mk_expr_node('num', 5),
 			    mk_expr_node('num', 6),
 			    mk_expr_node('num', 7)]),
    0);

$str = <<_KRL_;
[5, 6, temp]
_KRL_
add_expr_testcase(
    $str,
    "[5, 6, temp]",
     mk_expr_node('array', [mk_expr_node('num', 5),
 			    mk_expr_node('num', 6),
 			    mk_expr_node('num', 20)]),
    0);

$str = <<_KRL_;
[false, true, true, booltrue]
_KRL_
add_expr_testcase(
    $str,
    "[false, true, true, booltrue]",
     mk_expr_node('array', [mk_expr_node('bool', 'false'),
 			    mk_expr_node('bool', 'true'),
  			    mk_expr_node('bool', 'true'),
 			    mk_expr_node('bool', 'true')]),
    0);

$str = <<_KRL_;
[boolfalse, booltrue]
_KRL_
add_expr_testcase(
    $str,
    "[boolfalse, booltrue]",
     mk_expr_node('array', [mk_expr_node('bool', 'false'),
 			    mk_expr_node('bool', 'true')]),
    0);


$str = <<_KRL_;
page:id("foo")
_KRL_
add_expr_testcase(
    $str,
    'K$(\'foo\').innerHTML',
    mk_expr_node('JS', 'K$(\'foo\').innerHTML'),
    0);


$str = <<_KRL_;
page:id(city + "_ID")
_KRL_
add_expr_testcase(
    $str,
    'K$((city + \'_ID\')).innerHTML',
    mk_expr_node('JS', 'K$(\'Blackfoot_ID\').innerHTML'),
    0);



$str = <<_KRL_;
page:var("foo");
_KRL_
add_expr_testcase(
    $str,
    "",
     mk_expr_node('num', 5),
    0);



$str = <<_KRL_;
page:var("fo" + "o");
_KRL_
add_expr_testcase(
    $str,
    "",
     mk_expr_node('num', 5),
    0);


$str = <<_KRL_;
c = page:id("foo")
_KRL_
add_decl_testcase(
    $str,
    'K$(\'foo\').innerHTML',
    0);


$str = <<_KRL_;
page:env("foozle");
_KRL_
add_expr_testcase(
    $str,
    "",
     mk_expr_node('str', 'Foo'),
    0);

$str = <<_KRL_;
page:env("ip");
_KRL_
add_expr_testcase(
    $str,
    "",
     mk_expr_node('str', '128.187.16.242'),
    0);



$str = <<_KRL_;
c = 3;
_KRL_
add_decl_testcase(
    $str,
    '3',
    0);

$str = <<_KRL_;
c = 3 + a;
_KRL_
add_decl_testcase(
    $str,
    '13',
    0);


$str = <<_KRL_;
c = b * a;
_KRL_
add_decl_testcase(
    $str,
    '110',
    0);


$str = <<_KRL_;
c = b + store.pick("\$..book[1].price");
_KRL_
add_decl_testcase(
    $str,
    '23.99',
    0);


$str = <<_KRL_;
c = b + store.pick("\$..book[-1:].price");
_KRL_
add_decl_testcase(
    $str,
    '33.99',
    0);


$str = <<_KRL_;
c = "I love " + store.pick("\$..book[0].author");
_KRL_
add_decl_testcase(
    $str,
    'I love Nigel Rees',
    0);



#$krl = Kynetx::Parser::parse_decl($str);
#diag(Dumper($krl));


plan tests => 35 + (@expr_testcases * 2) + (@decl_testcases * 1);


# now test each test case twice
foreach my $case (@expr_testcases) {
    # diag(Dumper($case->{'expr'}));
    
    my $js = gen_js_expr($case->{'expr'});
    my $e = eval_js_expr($case->{'expr'}, $rule_env, $rule_name,$BYU_req_info);
    is($js,
       $case->{'js'},
       "Generating Javascript " . $case->{'src'});
    is_deeply($e, 
	      $case->{'val'},
	      "Evaling Javascript " . $case->{'src'});
    
}


# now test each test case twice
foreach my $case (@decl_testcases) {
    # diag(Dumper($case->{'expr'}));
    
    my $e = Kynetx::JavaScript::eval_js_decl(
	       $BYU_req_info, 
	       $rule_env, $rule_name, $this_session, 
	       $case->{'expr'}) ;
    is_deeply($e, 
	      $case->{'val'},
	      "Evaling Javascript " . $case->{'src'});
}



# 
# testing declarations and data sources
#

#sub gen_js_decl {
#   my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;



sub mk_datasource_function {
    my ($source, $args, $diag) = @_;

    return sub {

	my $function = shift; # name to test

	my $decl_src = <<_KRL_;
something = $source:$function($args);
_KRL_
        my $decl = Kynetx::Parser::parse_decl($decl_src);

	diag(Dumper($decl)) if $diag;

	my $js_decl = Kynetx::JavaScript::eval_js_decl(
	    $BYU_req_info,
	    $rule_env,
	    $rule_name,
	    $this_session,
	    $decl
	    );
	
        diag($decl->{'function'} . " --> " . $js_decl) if $diag;
	return $js_decl;
    };

}


# check referer datasource

my $referer_function = mk_datasource_function('referer','', 0);

is(&{$referer_function}('search_terms'), 
   'free+mobile+calls',
   'keywords from search engine referer' );



# check markets datasource
# http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG";
#    my $check_url = "http://foo";

    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", 11 if (! $response->is_success);

    my $symbol = 'GOOG'; 

# $symbol has to be a string that is itself a valid KRL string
    my $market_function = mk_datasource_function('stocks', '"'.$symbol.'"' , 0);

    my $curr_qr = qr#\d+\.\d\d#;

    is(&{$market_function}('symbol'), $symbol , "Returned symbol is the one we sent");


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

}


# check locations datasource

# http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG

my $location_function = mk_datasource_function('location', '', 0);



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

my $weather_function = mk_datasource_function('weather','', 0);

my $temp_qr = qr#\d+\.*\d*#;  # what a temperature looks like
like(&{$weather_function}('curr_temp'), $temp_qr, 'curr_temp');
like(&{$weather_function}('curr_cond'), qr#\w#, 'curr_cond');
like(&{$weather_function}('curr_cond_code'), qr#\d#, 'curr_cond_code');
like(&{$weather_function}('tomorrow_low'), $temp_qr, 'tomorrow_low');
like(&{$weather_function}('tomorrow_high'), $temp_qr, 'tomorrow_high');
like(&{$weather_function}('tomorrow_cond'), qr#\w#, 'tomorrow_cond');
like(&{$weather_function}('tomorrow_cond_code'), qr#\d+#, 'tomorrow_cond_code');


# check media market datasource

my $mm_function = mk_datasource_function('mediamarket','', 0);

like(&{$mm_function}('dma'), qr#\d\d\d#, 'dma');
like(&{$mm_function}('rank'), qr#\d+#, 'rank');
like(&{$mm_function}('name'), qr#\w#, 'name');
like(&{$mm_function}('households'), qr#\d+#, 'households');


# check user defined data sources
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "http://search.twitter.com/search.json?q=apple";

    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", 1 if (! $response->is_success);

    my $ds_function = mk_datasource_function('datasource','"q=rootbeer"', 0);
    contains_string(encode_json(&{$ds_function}('twitter_search')), 
		    '{"page":1,"query":"rootbeer","completed_in":', 
		    'user defined datasource');

}

my $no_escape = "foo bar is a boo bar";
my $pls_escape = "foo bar isn't a boo bar";
my $escaped = "foo bar isn\\'t a boo bar";
is(escape_js_str($no_escape), $no_escape, "Escape a string");
is(escape_js_str($pls_escape), $escaped, "Escape a string");

1;


