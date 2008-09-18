#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


use LWP::Simple;
use XML::XPath;

use Kynetx::Test qw/:all/;
use Kynetx::Predicates qw/:all/;
use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Parser;

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $rule_name = 'foo';

my $rule_env = {$rule_name . ':city' => 'Blackfoot',
		$rule_name . ':city2' => 'Seattle',
		$rule_name . ':tc' => '15',
		$rule_name . ':temp' => 20,
		$rule_name . ':booltrue' => 'true',
		$rule_name . ':boolfalse' => 'false',
               };



my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)
$Amazon_req_info->{'kvars'} = '{"foo": 5, "bar": "fizz", "bizz": [1, 2, 3]}';


my (@test_cases, $krl_src, $krl);

sub add_testcase {
    my($str, $expected, $req_info, $diag) = @_;
    my $val = Kynetx::Parser::parse_predexpr($str);
 
    chomp $str;
    diag("$str = ", Dumper($val)) if $diag;


    push(@test_cases, {'expr' => $val,
		       'val' => $expected,
		       'req_info' => $req_info,
		       'session' => {},
		       'src' =>  $str,
	 }
	 );
}


$krl_src = <<_KRL_;
urban()
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
rural()
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
median_income_above(5000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
median_income_below(50000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
urban() && median_income_below(50000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
urban() || median_income_below(50000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
rural() || median_income_below(50000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
urban() || median_income_below(1000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
not rural()
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
not urban() || not median_income_below(1000)
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
not (urban() && median_income_below(1000))
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );




$krl_src = <<_KRL_;
3 <= 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
5 <= 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
5 <= 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 >= 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
4 >= 6
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 >= 6
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 + 5 >= 4 + 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 + 5 <= 4 + 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
3 < 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
5 < 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
5 < 5
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 > 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 < 4
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 > 6
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 + 5 > 4 + 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 + 5 < 4 + 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
5 == 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 != 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
5 != 5
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 == 4
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
5 == 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
6 + 3 != 4 * 44 + 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
4 * 5 == 5 * 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
3* (4 + 5) == 3 * 5 + 3 * 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );





$krl_src = <<_KRL_;
3 <= temp
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp <= 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp <= temp
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp >= 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
4 >= temp
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp >= temp
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp + 5 >= temp + 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp + 5 <= temp + 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
3 < temp
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp < 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp < temp
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp > 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp < 4
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp > temp
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp + 5 > temp + 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp + 5 < temp + 3
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
temp == temp
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp != 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp != temp
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp == 4
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
temp == temp
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
temp + 3 != temp * 44 + 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
4 * temp == temp * 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
3* (4 + temp) == 3 * temp + 3 * 4
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );





$krl_src = <<_KRL_;
"foo" eq "foo"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"foo" eq "bar"
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
"foo" neq "foo"
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"foo" neq "bar"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
city eq "Blackfoot"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"foo" eq city
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
"Blackfoot" neq city
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
city neq "bar"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );




$krl_src = <<_KRL_;
"foobar" like "foo.*"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"bar" like ".*bar"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"foobar" like "^bar"
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"bar" like "foo.*"
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
"bar" like "foo.*"
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
stocks:symbol("GOOG") eq "GOOG"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
stocks:last("GOOG") > 1.00
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
location:country_code() eq "US"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
location:country_code() eq "GB"
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
location:country_code() eq "US" && urban() 
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
page:var("foo") > 3
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
page:var("foo") >= 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
3 + page:var("foo") >= 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
page:var("foo") * 2 >= 5
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
3 < page:var("foo") * 2 
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
page:var("bar") eq "fizz"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
page:var("bar") + "er" eq "fizzer"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


#$krl = Kynetx::Parser::parse_predexpr($krl_src);
#diag(Dumper($krl));


#
# Booleans
#

$krl_src = <<_KRL_;
true == true
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
true == false
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
true != true
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
true != false
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
true
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
false
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
true && true
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
true && false
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
false && true
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
false && false
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
true || true
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
true || false
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
false || true
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
false || false
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );




$krl_src = <<_KRL_;
not true
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
not false
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
not true || not true
_KRL_
add_testcase(
    $krl_src,
    0,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
not true || not false
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
not false || not true
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
not false || not false
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );



$krl_src = <<_KRL_;
urban() && "Seattle" eq location:city() 
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
urban() && location:city() eq "Seattle"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
urban() && city2 eq location:city() 
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
urban() && location:city() eq city2
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );

$krl_src = <<_KRL_;
urban() && location:city() eq "Sea" + "ttle"
_KRL_
add_testcase(
    $krl_src,
    1,
    $Amazon_req_info
    );


#$krl = Kynetx::Parser::parse_predexpr($krl_src);
#diag(Dumper($krl));


plan tests => 0 + (@test_cases * 1);



# now test each test case twice
foreach my $case (@test_cases) {
    # diag(Dumper($case->{'expr'}));
    is(eval_predicates($case->{'req_info'}, 
		       $rule_env, 
		       $case->{'session'}, 
		       $case->{'expr'},
		       $rule_name
       ),
       $case->{'val'},
       "Evaling predicate " . $case->{'src'});
    
}

exit;

my @rule;


my $Mobile_req_info;
$Mobile_req_info->{'ua'} = 'BlackBerry8320/4.3.1 Profile/MIDP-2.0 Configuration/CLDC-1.1';

# now make it mobile
$rule[0]->{'predicate'} = 'mobile';

ok(eval_predicates($Mobile_req_info, $rule_env, 0, \@rule),
   'testing mobile()');

$Mobile_req_info->{'ua'} = '"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12';


ok(! eval_predicates($Mobile_req_info, $rule_env, 0, \@rule),
   'testing not mobile()');

1;


