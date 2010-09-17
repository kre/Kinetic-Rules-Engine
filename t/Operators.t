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
use lib qw(/web/lib/perl);
use strict;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

use Test::More;
use Test::LongString;
use Test::Deep;

use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use Apache::Session::Memcached;



my $logger = get_logger();

use Data::Dumper;

use Kynetx::Test qw/:all/;
use Kynetx::Operators qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Memcached;


$Data::Dumper::Indent = 1;


my $rid = 'abcd1234';
my $rule_name = 'foo';

my $r = Kynetx::Test::configure();

my $req_info = Kynetx::Test::gen_req_info($rid);

my $init_rule_env = empty_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $turl = "http://www.htmldog.com/examples/tablelayout1.html";
my $durl = "http://www.htmldog.com/examples/darwin.html";
my $content = Kynetx::Memcached::get_remote_data($turl,3600);
my $content2 = Kynetx::Memcached::get_remote_data($durl,3600);


my $p = << "_KRL_";
pre {
  a = 10;
  b = 11;
  c = [4,5,6];
  i = [7,3,5,2,1,6];
  d = [];
  e = "this";
  f = [7,4,3,5,2,1,6];
  g = 5;
  h = [1,2,1,3,4,3,5,4,6,5];
  foo = "I like cheese";
  my_str = "This is a string";
  split_str = "A;B;C";
  my_url = "http://www.amazon.com/gp/products/123456789/";
  in_str = <<
  th[colspan="2"]
>>;
  my_jstr = <<
    {"www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]}
>>;
  bad_jstr = <<
    "www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]}
>>;
  a_s = ['apple','pear','orange','tomato'];
  b_s = ['string bean','corn','carrot','tomato','spinach'];
  c_s = ['wheat','barley','corn','rice'];
  d_s = ['','pear','corn'];
  e_s = '';
  f_s = ['corn','tomato'];
  g_s = ['corn','tomato','tomato','tomato','sprouts','lettuce','sprouts'];
  q_html = <<$content>>;
  r_html = <<$content2>>;
  html_arr = [q_html,r_html];
  meta_str = <<td[style="background: #ddf;"]>>;
  mail_str = <<
  Dear Scott,

  We have placed your MRI images in your Personal Data Store. Based on the
  results we recommend that you select an orthopedic surgeon and set an
  appointment for a consultation. Please call our office with any questions.
  Next steps:
      * Select an orthopedic surgeon
      * Set an appointment for a consultation



  Best Regards,

  The office of Dr. William Chan

  >>;
  mail2_str = << Dear Scott,\r\n\r\nWe have placed your MRI images in your Personal Data Store. Based on the \r\nresults we recommend that you select an orthopedic surgeon and set an \r\nappointment for a consultation. Please call our office with any questions.\r\n\r\nNext steps:\r\n\r\n    * Select an orthopedic surgeon\r\n    * Set an appointment for a consultation\r\n\r\n\r\nBest Regards,\r\n\r\nThe office of Dr. William Chan\r\n>>;
  a_h = { "colors of the wind" : "many","pi as array" : [3,1,4,1,5,6,9]};
  b_h = {"mKey" : "mValue"};
  c_h = [{"hKey" : "hValue"}];
  d_h = [{"hKey" : "hValue"},{"mKey" : "mValue"}];
  e_h = [{"hKey" : "hValue"},{"mKey" : "mValue"},"Thing"];
  f_h = {"hKey" : {"innerKey" : "innerVal"}};
  g_h = {"hKey" : {"innerKey" : "REPLACED"}};
  i_h = {"hKey" : {"innerKey" : "innerVal"},"mKey" : "mValue"};
}

_KRL_

$logger->debug("Parsing pre block");
my $ptree = Kynetx::Parser::parse_pre($p);


$logger->debug("Evaluating expressions");
my ($js, $rule_env) = Kynetx::Expressions::eval_prelude($req_info,
							$init_rule_env,
							$rule_name,
							$session,
							$ptree);

# $rule_env = extend_rule_env(
#     ['a','b','c','d','e','my_str','my_url'],
#     [10, 11, [4,5,6], [], 'this', 'This is a string', 'http://www.amazon.com/gp/products/123456789/'],
#     $init_rule_env);



$rule_env = extend_rule_env('store', {
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
	},
	"kynetx.com" => {"link" => "http://www.kynetx.com",
			 "text" => "Simply the hottest company around!"
	}
}, $rule_env);


#diag Dumper($rule_env);

my (@e, @x, @d);

my $i = 0;

sub test_operator {
    my ($e, $x, $d) = @_;

    my ($v, $r);

    diag "Expr: ", Dumper($e) if $d;

    $v = Kynetx::Parser::parse_expr($e);
    diag "Parsed expr: ", Dumper($v) if $d;

    $r = eval_expr($v, $rule_env, $rule_name,$req_info);
    diag "Result: ", Dumper($r) if $d;
    my $result = cmp_deeply($r, $x, "Trying $e");
    #die unless ($result);
}


#goto ENDY;

$e[$i] = q/store.pick("$.store.book[*].author")/;
$x[$i] = {
   'val' => [
     'Nigel Rees',
     'Evelyn Waugh',
     'Herman Melville',
     'J. R. R. Tolkien'
   ],
   'type' => 'array'
};
$i++;

$e[$i] = q/store.pick("$..author")/;
$x[$i] = {
   'val' => [
     'Nigel Rees',
     'Evelyn Waugh',
     'Herman Melville',
     'J. R. R. Tolkien'
   ],
   'type' => 'array'
};
$i++;

$e[$i] = q/store.pick("$..book[?(@.price<10)]")/;
$x[$i] = {
'val' => [
     {
       'ratings' => [
         1,
         3,
         2,
         10
       ],
       'price' => '8.95',
       'title' => 'Sayings of the Century',
       'author' => 'Nigel Rees',
       'category' => 'reference'
     },
     {
       'price' => '8.99',
       'isbn' => '0-553-21311-3',
       'title' => 'Moby Dick',
       'author' => 'Herman Melville',
       'category' => 'fiction'
     }
   ],
   'type' => 'array'
};
$i++;


$e[$i] = q/store.pick("$..book[?(@.price == 8.99)]")/;
$x[$i] = {
 'val' =>
     {
       'price' => '8.99',
       'isbn' => '0-553-21311-3',
       'title' => 'Moby Dick',
       'author' => 'Herman Melville',
       'category' => 'fiction'
     },
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/store.pick("$..book[?(@.price == 8.99)]")/;
$x[$i] = {
 'val' =>
     {
       'price' => '8.99',
       'isbn' => '0-553-21311-3',
       'title' => 'Moby Dick',
       'author' => 'Herman Melville',
       'category' => 'fiction'
     },
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/store.pick("$..book[?(@.price != 8.99)]")/;
$x[$i] = {
 'val' => [
     {
       'ratings' => [
         1,
         3,
         2,
         10
       ],
       'price' => '8.95',
       'title' => 'Sayings of the Century',
       'author' => 'Nigel Rees',
       'category' => 'reference'
     },
     {
       'ratings' => [
         'good',
         'bad',
         'lovely'
       ],
       'price' => '12.99',
       'title' => 'Sword of Honour',
       'author' => 'Evelyn Waugh',
       'category' => 'fiction'
     },
     {
       'price' => '22.99',
       'isbn' => '0-395-19395-8',
       'title' => 'The Lord of the Rings',
       'author' => 'J. R. R. Tolkien',
       'category' => 'fiction'
     }
   ],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[?(@.title eq 'Moby Dick')]")/;
$x[$i] = {
'val' =>
     {
       'price' => '8.99',
       'isbn' => '0-553-21311-3',
       'title' => 'Moby Dick',
       'author' => 'Herman Melville',
       'category' => 'fiction'
     },
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[?(@.title ne 'Moby Dick')]")/;
$x[$i] = {
'val' => [
     {
       'ratings' => [
         1,
         3,
         2,
         10
       ],
       'price' => '8.95',
       'title' => 'Sayings of the Century',
       'author' => 'Nigel Rees',
       'category' => 'reference'
     },
     {
       'ratings' => [
         'good',
         'bad',
         'lovely'
       ],
       'price' => '12.99',
       'title' => 'Sword of Honour',
       'author' => 'Evelyn Waugh',
       'category' => 'fiction'
     },
     {
       'price' => '22.99',
       'isbn' => '0-395-19395-8',
       'title' => 'The Lord of the Rings',
       'author' => 'J. R. R. Tolkien',
       'category' => 'fiction'
     }
   ],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$.store..price")/;
$x[$i] = {
'val' => [
     '19.95',
     '8.95',
     '12.99',
     '8.99',
     '22.99'
   ],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[0,1]")/;
$x[$i] = {
'val' => [
     {
       'ratings' => [
         1,
         3,
         2,
         10
       ],
       'price' => '8.95',
       'title' => 'Sayings of the Century',
       'author' => 'Nigel Rees',
       'category' => 'reference'
     },
     {
       'ratings' => [
         'good',
         'bad',
         'lovely'
       ],
       'price' => '12.99',
       'title' => 'Sword of Honour',
       'author' => 'Evelyn Waugh',
       'category' => 'fiction'
     }
   ],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[0].price") + a/;
$x[$i] = {'val' => '18.95',
	  'type' => 'num'};
$d[$i]  = 0;
$i++;

$e[$i] = q/b + store.pick("$..book[1].price")/;
$x[$i] = {'val' => '23.99',
	  'type' => 'num'};
$d[$i]  = 0;
$i++;

$e[$i] = q#{"foo":1,"bar":2}.pick("$.foo")#;
$x[$i] = {
   'val' => 1,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#{"foo":1,"bar":2}.pick("$.bar")#;
$x[$i] = {
   'val' => 2,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;



#-----------------------------------------------------------------------------------
# array operators
#-----------------------------------------------------------------------------------

$e[$i] = q/c.length()/;
$x[$i] = {
   'val' => 3,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/d.length()/;
$x[$i] = {
   'val' => 0,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/(store.pick("$..book[0,1]")).length()/;
$x[$i] = {
   'val' => 2,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/(store.pick("$.kynetx\.com.text"))/;
$x[$i] = {
   'val' => 'Simply the hottest company around!',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

#-------------------------------------------------------------------------------------
# Special case as()
#-------------------------------------------------------------------------------------

$e[$i] = q/my_jstr.as("json")/;
$x[$i] = {
    "val" => {
    "www.barnesandnoble.com"=>[
            {"link"=>"http://aaa.com/barnesandnoble",
             "text"=>"AAA members save money!",
             "type"=>"AAA"}
        ]
    },
    "type" => "hash"
};
$d[$i] = 0;
$i++;

$e[$i] = q/my_jstr.as("json").pick("$..text")/;
$x[$i] = {
    "val" => "AAA members save money!",
    "type" => "str"
};
$d[$i] = 0;
$i++;

#newparser format

diag("Okay to ignore JSON parse error");
$e[$i] = q/bad_jstr.as("json")/;
$x[$i] = {
    "val" => "\n".'    "www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]}
',
    "type" => "str"
};
$d[$i] = 0;
$i++;


$e[$i] = q#my_str.replace(re/string/,"puppy")#;
$x[$i] = {
   'val' => 'This is a puppy',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(re/string/,"puppy")#;
$x[$i] = {
   'val' => 'This is a puppy',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(re/is/,"ese")#;
$x[$i] = {
   'val' => 'These is a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(re/is/g,"ese")#;
$x[$i] = {
   'val' => 'These ese a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(re/this/,"do you want a")#;
$x[$i] = {
   'val' => 'This is a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(re/this/i,"do you want a")#;
$x[$i] = {
   'val' => 'do you want a is a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(re/Th(is)/,"Nothing $1")#;
$x[$i] = {
   'val' => 'Nothing is is a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_url.replace(re/http:\/\/([A-Za-z0-9.-]+)\/.*/,"$1")#;
$x[$i] = {
   'val' => 'www.amazon.com',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(("re/this/"+ "i").as("regexp"),"do you want a")#;
$x[$i] = {
   'val' => 'do you want a is a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.replace(("re/"+ e + "/i").as("regexp"),"do you want a")#;
$x[$i] = {
   'val' => 'do you want a is a string',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_url.replace(#http://www.amazon.com#,"foozle::")%;
$x[$i] = {
   'val' => 'foozle::/gp/products/123456789/',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#my_str.match(re/string/)#;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#my_str.match(re/string/)#;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#my_str.match(re/strung/)#;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_str.match(#string#)%;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_str.match(#strung#)%;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_url.match(#http://www.amazon.com#)%;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_str.match(#https://www.amazon.com#)%;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;



$e[$i] = q#my_str.uc()#;
$x[$i] = {
    'val' => 'THIS IS A STRING',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q#my_str.lc()#;
$x[$i] = {
    'val' => 'this is a string',
    'type' => 'str'
};
$d[$i] = 0;
$i++;


$e[$i] = q#split_str.split(re/;/)#;
$x[$i] = {
    'val' => ['A','B','C'],
    'type' => 'array'
};
$d[$i] = 0;
$i++;


#
# testing array ops
#
$e[$i] = q#c.length()#;
$x[$i] = {
   'val' => 3,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.head()#;
$x[$i] = {
   'val' => 4,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#c.tail()#;
$x[$i] = {
   'val' => [5,6],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.tail().length()#;
$x[$i] = {
   'val' => 2,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#c.sort()#;
$x[$i] = {
   'val' => [4,5,6],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#f.sort()#;
$x[$i] = {
   'val' => [1,2,3,4,5,6,7],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#[6,4,5].sort()#;
$x[$i] = {
   'val' => [4,5,6],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#c.sort("reverse")#;
$x[$i] = {
   'val' => [6,5,4],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.sort(function(a,b){b > a})#;
$x[$i] = {
   'val' => [6,5,4],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#f.filter(function(a){a < 5})#;
$x[$i] = {
   'val' => [4,3,2,1],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#f.filter(function(a){a < 5}).sort()#;
$x[$i] = {
   'val' => [1,2,3,4],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#c.map(function(a){a + 2}).sort()#;
$x[$i] = {
   'val' => [6,7,8],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.sort().map(function(a){a + 2})#;
$x[$i] = {
   'val' => [6,7,8],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.join(";")#;
$x[$i] = {
   'val' => '4;5;6',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#a_s.append(b_s)#;
$x[$i] = {
   'val' => ['apple','pear','orange','tomato',
	     'string bean','corn','carrot','tomato','spinach'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#a_s.append(a)#;
$x[$i] = {
   'val' => ['apple','pear','orange','tomato',
	     10],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#a.append(a_s)#;
$x[$i] = {
   'val' => [10,
	     'apple','pear','orange','tomato'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#a.append(b)#;
$x[$i] = {
   'val' => [10,
	     11],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#c_h.append(d_h)#;
$x[$i] = {
   'val' => [{"hKey" => "hValue"},{"hKey" => "hValue"},{"mKey" => "mValue"}],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#c_h.append(b_h)#;
$x[$i] = {
   'val' => [{"hKey" => "hValue"},{"mKey" => "mValue"}],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


#-----------------------------------------------------------------------------------
# set operators
#-----------------------------------------------------------------------------------

$e[$i] = q/c.intersection(i)/;
$x[$i] = {
   'val' => bag(5,6),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.intersection(b_s)/;
$x[$i] = {
   'val' => bag('tomato'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/(c.intersection(i)).intersection(g)/;
$x[$i] = {
   'val' => bag(5),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.intersection(c_s)/;
$x[$i] = {
   'val' => bag(),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.intersection(a_s)/;
$x[$i] = {
   'val' => bag('apple','orange','pear','tomato'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.intersection(d)/;
$x[$i] = {
   'val' => bag(),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.intersection(d_s)/;
$x[$i] = {
   'val' => bag('pear'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/e_s.intersection(d_s)/;
$x[$i] = {
   'val' => bag(''),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.union(c_s)/;
$x[$i] = {
   'val' => bag('apple',
     'barley',
     'corn',
     'orange',
     'pear',
     'rice',
     'tomato',
     'wheat'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/i.union(d)/;
$x[$i] = {
   'val' => bag(7,3,5,2,1,6),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/c.difference(i)/;
$x[$i] = {
   'val' => bag(4),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/a_s.difference(b_s)/;
$x[$i] = {
   'val' => bag('apple','orange','pear'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/(c.difference(i)).difference(g)/;
$x[$i] = {
   'val' => bag(4),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.difference(c_s)/;
$x[$i] = {
   'val' => bag('apple','pear','orange','tomato'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.difference(a_s)/;
$x[$i] = {
   'val' => bag(),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.difference(d)/;
$x[$i] = {
   'val' => bag('apple','pear','orange','tomato'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.difference(d_s)/;
$x[$i] = {
   'val' => bag('apple','orange','tomato'),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/e_s.difference(d_s)/;
$x[$i] = {
   'val' => bag(),
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/i.has(g)/;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.has(b_s)/;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/b_s.has(f_s)/;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/a_s.has(d)/;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/a_s.has(a_s)/;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/h.once()/;
$x[$i] = {
   'val' => [6,2],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/g_s.once()/;
$x[$i] = {
   'val' => ['lettuce','corn'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q/h.duplicates()/;
$x[$i] = {
   'val' => [4,1,3,5],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/g_s.duplicates()/;
$x[$i] = {
   'val' => ['tomato','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/h.unique()/;
$x[$i] = {
   'val' => [1,2,3,4,5,6],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/g_s.unique()/;
$x[$i] = {
   'val' => ['corn','lettuce','sprouts','tomato'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


my $list = Kynetx::Operators::list_extensions();
$logger->debug("Extensions: ", sub {Dumper($list)});

$e[$i] = q/q_html.query("table tr td[style],table tr th")/;
$x[$i] = {
   'val' => [
     '<td style="background: #ddf;">Grey Wolf</td>
',
     '<td style="background: #ddf;">Cape hunting dog</td>
',
     '<td style="background: #ddf;">Very silly big long-long named dog woof</td>
',
     '<td style="background: #ddf;">Red Fox</td>
',
     '<td style="background: #ddf;">Fennec</td>
',
     '<th>Apes</th>
',
     '<th colspan="2">Cats</th>
',
     '<th style="background: #ddf;">Dogs</th>
',
     '<th>Lemurs</th>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/html_arr.query("caption,h1")/;
$x[$i] = {
   'val' => [
    '<caption>Animal groups</caption>
',
    '<h1>Charles Darwin</h1>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/html_arr.query(["caption","h1"])/;
$x[$i] = {
   'val' => [
    '<caption>Animal groups</caption>
',
    '<h1>Charles Darwin</h1>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;


$e[$i] = q/q_html.query(in_str)/;
$x[$i] = {
   'val' => [
    '<th colspan="2">Cats</th>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/q_html.query([in_str,"th"])/;
$x[$i] = {
   'val' => [
    '<th colspan="2">Cats</th>
',
     '<th>Apes</th>
',
     '<th colspan="2">Cats</th>
',
     '<th style="background: #ddf;">Dogs</th>
',
     '<th>Lemurs</th>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/html_arr.query([in_str,"th","h2"])/;
$x[$i] = {
   'val' => [
    '<th colspan="2">Cats</th>
',
     '<th>Apes</th>
',
     '<th colspan="2">Cats</th>
',
     '<th style="background: #ddf;">Dogs</th>
',
     '<th>Lemurs</th>
',
    '<h2>On the Origin of The Origin</h2>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/q_html.query("#{in_str}")/;
$x[$i] = {
   'val' => [
    '<th colspan="2">Cats</th>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/q_html.query(meta_str)/;
$x[$i] = {
   'val' => [
     '<td style="background: #ddf;">Grey Wolf</td>
',
     '<td style="background: #ddf;">Cape hunting dog</td>
',
     '<td style="background: #ddf;">Very silly big long-long named dog woof</td>
',
     '<td style="background: #ddf;">Red Fox</td>
',
     '<td style="background: #ddf;">Fennec</td>
'
   ],
   'type' => 'array'
};
$d[$i] = 0;
$i++;


$e[$i] = q/a_h.put(b_h)/;
$x[$i] = Kynetx::Expressions::typed_value({
  'val' => {
    'pi as array' => [
        3,1,4,1,5,6,9,
      ],
    'colors of the wind' => 'many',
    'mKey' => 'mValue'
    },
'type' => 'hash'
});
$d[$i] = 0;
$i++;

$e[$i] = q/b_h.put(f_h)/;
$x[$i] = {
    'val' => {
      'mKey' => 'mValue',
      'hKey' => {
        'innerKey' => 'innerVal'
       }
    },
    'type' => 'hash'
};
$d[$i] = 0;
$i++;



$e[$i] = q/i_h.put(g_h)/;
$x[$i] = {
    'val' => {
      'mKey' => 'mValue',
      'hKey' => {
          'innerKey' => 'REPLACED'
      }
     },
    'type' => 'hash'
};
$d[$i] = 0;
$i++;


$e[$i] = q/i_h.as("str")/;
$x[$i] = {
    'val' => '{"mKey":"mValue","hKey":{"innerKey":"innerVal"}}',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/c_h.as("str")/;
$x[$i] ={
    'val' => '[{"hKey":"hValue"}]',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/d_h.as("str")/;
$x[$i] ={
    'val' => '[{"hKey":"hValue"},{"mKey":"mValue"}]',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/a_h.as("json")/;
$x[$i] = {
    'val' => '{"pi as array":[3,1,4,1,5,6,9],"colors of the wind":"many"}',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

ENDY:

$e[$i] = q#my_str.extract(re/(is)/)#;
$x[$i] = {
   'val' => ['is'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#foo.extract(re/like (\w+)/)#;
$x[$i] = {
   'val' => ['cheese'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.extract(re/(s.+).*(.ing)/)#;
$x[$i] = {
   'val' => ['s is a st','ring'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.extract(re/(boot)/)#;
$x[$i] = {
   'val' => [],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;



$e[$i] = q#mail2_str.extract(re/\s*\*\s*([ \w]+)\s*\v\s*\*\s*([ \w]+)\v/)#;
$x[$i] = {
   'val' => ['Select an orthopedic surgeon','Set an appointment for a consultation'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#foo.extract(re/(e)/g)#;
$x[$i] = {
   'val' => ['e','e','e','e'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#foo.extract(re/e/g)#;
$x[$i] = {
   'val' => ['e','e','e','e'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#mail2_str.extract(re/^\s*\*\s*([ \w]+)/mg)#;
$x[$i] = {
   'val' => ['Select an orthopedic surgeon','Set an appointment for a consultation'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#mail2_str.extract(re/\bs\w*/gi)#;
$x[$i] = {
   'val' => ['Scott','Store','select','surgeon','set','steps','Select','surgeon','Set'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


# now run the tests....
my $l = scalar @e;
plan tests => $l;

my $j;
for ($j = 0; $j < $i; $j++) {
    test_operator($e[$j], $x[$j], $d[$j]);
}






1;


