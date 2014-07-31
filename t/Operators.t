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

my $turl = "http://www.htmliseasy.com/exercises/example_06c.html";
my $durl = "http://www.htmliseasy.com/exercises/example_02d.html";
#diag "Fetching test content from: $turl";
my $content = Kynetx::Memcached::get_remote_data($turl,3600);
#diag "Content for q_html: " , $content;
#diag "Fetching test content from: $durl";
my $content2 = Kynetx::Memcached::get_remote_data($durl,3600);


my $p = << "_KRL_";
pre {
  a = 10;
  b = 11;
  c = [4,5,6];
  d = [];
  e = "this";
  f = [7,4,3,5,2,1,6];
  g = 5;
  h = [1,2,1,3,4,3,5,4,6,5];
  i = [7,3,5,2,1,6];
  j = [{"a" : 1, "b" : 2, "c": 3}, {"a" : 4, "b" : 5, "c": 6}, {"a" : 7, "b" : 8, "c": 9}];
  k = [100, 1, 10, 1000, 21, 92];
  m = [76];
  n = "76";

  simple_a_of_a = [["test", 80], ["foo", 100]];
  simple_map = {"test": 80, "foo": 100};

  mixed_array = [1, 'abe', re/foo.*/, true, false, 56];

  edo = [{"a" : 2}, {"b" : 26}, {"c" : 5}, {"d" : 16}, {"e": 29}];
  //edo = [{"a bc" : 15}, {"b ad" : 26}, {"c" : 5}, {"d" : 16}, {"e": 2}];
  //edo = [{'crazy chicken' :1}, {'massaman curry ***' :5}, {'pad thai' :3}, {'chinese' :1}, {'j dogs' :2}, {'thai pad' :2}, {'el pollo loco' :1}, {'jcw pastrami burger' :1}, {'costco pizza' :1}, {'jimmy johns' :3}];
  employees = [{'name' : 'Ron', 'dept': 'marketing'}, {'name' : 'Steve', 'dept' : 'executive'}, {'name': 'Mark', 'dept': 'engr'}];
  foo = "I like cheese";
  my_str = "This is a string";
  spacey_str = "    spaces     \n";
  phone_num = "1234567890";
  split_str = "A;B;C";
  my_url = "http://www.amazon.com/gp/products/123456789/";
  in_str = <<
  font[size="2"]
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
  j_h = { "colors of the wind" : "many","pi as array" : [3,1,4,1,5,6,9],"foo" : {"bar" : {10:"I like cheese"}}};
  k_h = {1: {"A" : {"a":"1Aa","b":"1Ab"}},2:"qwerty","3":{"snicker":"snee", "7":5}};
  
  a_path = ["foo"];
  b_path = ["foo","bar"];
  c_path = ["foo",10,"bar"];
  d_path = ["hKey","innerKey"];

  map1 = {"a": 4, "b" : 6, "c" : 7, "d": 2};
  map2 = {"a": 4, "b" : [4,5,6], "c" : 7, "d": 2};

  edo_func = function(a,b) {
		      (a{a.keys().head()} <=> b{b.keys().head()})
                    };

  newsfeed = {"N7" : {"updated" : "2013-06-20T14:03:00-06:00"},
              "N2" : {"updated" : "2013-06-19T14:03:00-06:00"},
              "N5" : {"updated" : "2013-06-21T14:03:00-06:00"}};

  newsItemCmp = function(a,b) {
		  atime = time:strftime(newsfeed{[a, "updated"]}, "%s");
		  btime = time:strftime(newsfeed{[b, "updated"]}, "%s");
 		  (atime <=> btime)
		};

  add_n = function(n) { 
            function(x) {
               x + n
            }
          };

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

    $r = eval_expr($v, $rule_env, $rule_name,$req_info, $session);
    diag "Expect: ", Dumper($x) if $d;
    diag "Result: ", Dumper($r) if $d;
    my $result = cmp_deeply($r, $x, "Trying $e");   
    
    
    die unless ($result);
}

##
# sort
##
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

$e[$i] = q#k.sort("numeric")#;
$x[$i] = {
   'val' => [1,10, 21,92,100,1000],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#k.sort("ciremun")#;
$x[$i] = {
   'val' => [1000,100,92,21,10,1],
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


$e[$i] = q#edo.sort(function(a,b) {
		      (a{a.keys().head()} <=> b{b.keys().head()})
                    }
	           )#;
$x[$i] = {
   'val' => [  {'a' => 2},
	       {'c' => 5},
	       {'d' => 16},
	       {'b' => 26},
	       {'e' => 29}
	    ],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#edo.sort(edo_func)#;
$x[$i] = {
   'val' => [  {'a' => 2},
	       {'c' => 5},
	       {'d' => 16},
	       {'b' => 26},
	       {'e' => 29}
	    ],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#newsfeed.keys().sort(newsItemCmp)#;
$x[$i] = {
   'val' => ["N2", "N7", "N5"],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;




$e[$i] = q#newsfeed.keys().sort(function(a,b) {
 		  newsfeed{[a, "updated"]} cmp newsfeed{[b, "updated"]}
		})#;
$x[$i] = {
   'val' => ["N2", "N7", "N5"],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


#goto ENDY;

##
# pick
##

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

$e[$i] = q#store.pick("$..book[?(@.title like '/M\w+ D\w+/')]")#;
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

$e[$i] = q#store.pick("$..book[?(@.title like '/^m\w+/i')]")#;
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

$e[$i] = q#store.pick("$..book[?(@.price == 8.99)]")#;
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

$e[$i] = q/store.pick("$..book[?(@.title neq 'Moby Dick')]")/;
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

$e[$i] = q/store.pick("$..book[?(@.ratings)]")/;
$x[$i] = {
'val' =>[{
      'ratings' => [
        1,
        3,
        2,
        10
      ],
      'category' => 'reference',
      'author' => 'Nigel Rees',
      'title' => 'Sayings of the Century',
      'price' => '8.95'
    },
    {
      'ratings' => [
        'good',
        'bad',
        'lovely'
      ],
      'category' => 'fiction',
      'author' => 'Evelyn Waugh',
      'title' => 'Sword of Honour',
      'price' => '12.99'
    }],
    'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[?(@.ratings)]").length() > 0/;
$x[$i] = {
'val' => 'true',
'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[?(@.ratings)]").length() > 3/;
$x[$i] = {
'val' => 'false',
'type' => 'bool'
};
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

$e[$i] = q#{"foo":1,"bar":2}.pick("$.bar", true)#;
$x[$i] = {
   'val' => [2],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#{"foo":1,"bar":2}.pick("$.bar", true).head()#;
$x[$i] = {
   'val' => 2,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#{"foo":1,"bar":2}.pick("$.brik", true).head() || ""#;
$x[$i] = {
   'val' => "",
   'type' => 'str'
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

$e[$i] = q#a.as("str")#;
$x[$i] = {
   'val' => '10',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#n.as("num")#;
$x[$i] = {
   'val' => 76,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q%my_url.replace(re#http://www.amazon.com#,"foozle::")%;
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


$e[$i] = q%my_str.match(re#string#)%;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_str.match(re#strung#)%;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_url.match(re#http://www.amazon.com#)%;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


$e[$i] = q%my_str.match(re#https://www.amazon.com#)%;
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


$e[$i] = q#a.sprintf("<% d>")#;
$x[$i] = {
    'val' => '< 10>',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q#phone_num.sprintf("<%12s>")#;
$x[$i] = {
    'val' => '<  1234567890>',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!"012".sprintf("<%#.5o>")!;
$x[$i] = {
    'val' => '<00014>',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!my_str.substr(5)!;
$x[$i] = {
    'val' => 'is a string',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!my_str.substr(5, 4)!;
$x[$i] = {
    'val' => 'is a',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!my_str.substr(25)!;
$x[$i] = {
    'val' => undef,
    'type' => 'null'
};
$d[$i] = 0;
$i++;

$e[$i] = q!my_str.substr(5, -5)!;
$x[$i] = {
    'val' => 'is a s',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!my_str.length()!;
$x[$i] = {
    'val' => 16,
    'type' => 'num'
};
$d[$i] = 0;
$i++;

$e[$i] = q!my_str.lc().capitalize()!;
$x[$i] = {
    'val' => 'This is a string',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!spacey_str.trim()!;
$x[$i] = {
    'val' => 'spaces',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q!"a".range("z").length()!;
$x[$i] = {
    'val' => 26,
    'type' => 'num'
};
$d[$i] = 0;
$i++;

$e[$i] = q!(0).range(3)!;
$x[$i] = {
    'val' => [0, 1, 2, 3],
    'type' => 'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q!(0).range(3).reduce(function(a,b){a + b})!;
$x[$i] = {
    'val' => 6,
    'type' => 'num'
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


$e[$i] = q#j.filter(function(a){a.pick("$..b") < 7})#;
$x[$i] = {
   'val' => [{"a" => 1, "b" => 2, "c"=> 3}, {"a" => 4, "b" => 5, "c"=> 6}],
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


$e[$i] = q#map1.filter(function(k,v){v > 5})#;
$x[$i] = {
   'val' => {"b" => 6, "c" => 7},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#map1.filter(function(k,v){k eq "a"})#;
$x[$i] = {
   'val' => {"a" => 4},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;


$e[$i] = q#map2.filter(function(k,v){v > 5})#;
$x[$i] = {
   'val' => {"b" => [4,5,6], "c" => 7},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#map2.filter(function(k,v){v.typeof() eq 'num' && v > 5})#;
$x[$i] = {
   'val' => {"c" => 7},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

#
# collect
#
$e[$i] = q#f.collect(function(a){(a < 5) => "x" | "y"})#;
$x[$i] = {
   'val' => {'x' => [4,3,2,1],
	     'y' => [7,5,6]},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#f.collect(function(a){(a % 2) => "odd" | "even"})#;
$x[$i] = {
   'val' => {'even' => [4,2,6],
	     'odd' => [7,3,5,1]},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#employees.collect(function(a){a{"dept"}})#;
$x[$i] = {
   'val' => {'marketing' => [
			    {
			     'dept' => 'marketing',
			     'name' => 'Ron'
			    }
			   ],
	     'engr' => [
			{
			 'dept' => 'engr',
			 'name' => 'Mark'
			}
		       ],
	     'executive' => [
			     {
			      'dept' => 'executive',
			      'name' => 'Steve'
			     }
			    ]
	    },
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;




#
# map
#

$e[$i] = q#j.map(function(a){a.pick("$..b")})#;
$x[$i] = {
   'val' => [2,5,8],
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

$e[$i] = q#map1.map(function(k,v){v + 2})#;
$x[$i] = {
   'val' => {"a" => 6, "b" => 8, "c" => 9, "d" => 4},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#map2.map(function(k,v){v.typeof() eq 'num' => v + 2 | 2})#;
$x[$i] = {
   'val' => {"a" => 6, "b" => 2, "c" => 9, "d" => 4},
   'type' => 'hash'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#(0).range(4).map(function(x){x+1000})#;
$x[$i] = {
   'val' => [1000, 1001, 1002, 1003, 1004],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#(0).range(4).map(add_n(1000))#;
$x[$i] = {
   'val' => [1000, 1001, 1002, 1003, 1004],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


#goto ENDY;


##
## pairwise
##

$e[$i] = q#[c,c].pairwise(function(a,b){a + b})#;
$x[$i] = {
   'val' => [8,10,12],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;


##
## any
##

$e[$i] = q#c.any(function(a){a > 5})#;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.any(function(a){a > 25})#;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


##
## none
##

$e[$i] = q#c.none(function(a){a > 5})#;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.none(function(a){a > 25})#;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

##
## all
##

$e[$i] = q#c.all(function(a){a > 5})#;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.all(function(a){a < 25})#;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


##
## notall
##

$e[$i] = q#c.notall(function(a){a > 5})#;
$x[$i] = {
   'val' => 'true',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.notall(function(a){a < 25})#;
$x[$i] = {
   'val' => 'false',
   'type' => 'bool'
};
$d[$i]  = 0;
$i++;


##
## reduce
##

$e[$i] = q#c.reduce(function(a,b){a + b})#;
$x[$i] = {
   'val' => 15,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.reduce(function(a,b){a + b}, 10)#;
$x[$i] = {
   'val' => 25,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#d.reduce(function(a,b){a + b})#;
$x[$i] = {
   'val' => 0,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#d.reduce(function(a,b){a + b}, 15)#;
$x[$i] = {
   'val' => 15,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#m.reduce(function(a,b){a + b})#;
$x[$i] = {
   'val' => 76,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#m.reduce(function(a,b){a + b}, 15)#;
$x[$i] = {
   'val' => 91,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#j.reduce(function(a,b){a * b{"a"}}, 1)#;
$x[$i] = {
   'val' => 28,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.reduce(function(a,b){a - b})#;
$x[$i] = {
   'val' => -7,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;



##
## reverse
##
$e[$i] = q#c.reverse()#;
$x[$i] = {
   'val' => [6,5,4],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;




##
## join
##
$e[$i] = q#c.join(";")#;
$x[$i] = {
   'val' => '4;5;6',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#d.join(";")#;
$x[$i] = {
   'val' => '',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;




##
## append
##
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

#------------------------------------------------------------------
# index
#------------------------------------------------------------------

$e[$i] = q#k.index(21)#;
$x[$i] = {
   'val' => 4,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.index(5)#;
$x[$i] = {
   'val' => 1,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.index(10)#;
$x[$i] = {
   'val' => -1,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.split(re/ /).index('a')#;
$x[$i] = {
   'val' => 2,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#my_str.split(re/ /).index('st')#;
$x[$i] = {
   'val' => -1,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

#   mixed_array = [1, 'abe', re/foo.*/, true, false, 56];
$e[$i] = q#mixed_array.index(1)#;
$x[$i] = {
   'val' => 0,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;


#   mixed_array = [1, 'abe', re/foo.*/, true, false, 56];
$e[$i] = q#mixed_array.index('abe')#;
$x[$i] = {
   'val' => 1,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

#   mixed_array = [1, 'abe', re/foo.*/, true, false, 56];
$e[$i] = q#mixed_array.index(re/foo.*/)#;
$x[$i] = {
   'val' => 2,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

#   mixed_array = [1, 'abe', re/foo.*/, true, false, 56];
$e[$i] = q#mixed_array.index(true)#;
$x[$i] = {
   'val' => 3,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;

#   mixed_array = [1, 'abe', re/foo.*/, true, false, 56];
$e[$i] = q#mixed_array.index(false)#;
$x[$i] = {
   'val' => 4,
   'type' => 'num'
};
$d[$i]  = 0;
$i++;



#------------------------------------------------------------------
# typeof
#------------------------------------------------------------------

$e[$i] = q#c.typeof()#;
$x[$i] = {
   'val' => 'array',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#a.typeof()#;
$x[$i] = {
   'val' => 'num',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#e.typeof()#;
$x[$i] = {
   'val' => 'str',
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#simple_map.typeof()#;
$x[$i] = {
   'val' => 'hash',
   'type' => 'str'
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

if ($content) {      
    
    $e[$i] = q/q_html.query("table tr td b, font[size='5']",1)/;
    $x[$i] = {
       'val' => bag(
         'My tech stock picks',
         'My tech stock picks',
         'NAME',
         'SYMBOL',
         'CURRENT',
         '52WK HI',
         '52WK LO',
         'P/E RATIO'
       ),
       'type' => 'array'
    };
    $d[$i] = 0;
    $i++;
    
    $e[$i] = q/q_html.query(in_str)/;
    $x[$i] = {
       'val' => [
         '<font size="2"><b>NAME</b></font>',
         '<font size="2"><b>SYMBOL</b></font>',
         '<font size="2"><b>CURRENT</b></font>',
         '<font size="2"><b>52WK HI</b></font>',
         '<font size="2"><b>52WK LO</b></font>',
         '<font size="2"><b>P/E RATIO</b></font>'
       ],
       'type' => 'array'
    };
    $d[$i] = 0;
    $i++;

} else {
    $logger->debug("Skipped tests to $turl");   
}

if ($content2 && $content) {
    $e[$i] = q/html_arr.query(["table tr td b", "font[size='5']"])/;
    $x[$i] = {
       'val' => bag(
         '<b>52WK HI</b>', 
         '<b>52WK LO</b>', 
         '<b>CURRENT</b>', 
         '<b>My tech stock picks</b>', 
         '<b>NAME</b>', 
         '<b>P/E RATIO</b>', 
         '<b>SYMBOL</b>', 
         '<font size="5"><i><b>My tech stock picks</b></i></font>'
       ),
       'type' => 'array'
    };
    $d[$i] = 0;
    $i++;
    
    
    $e[$i] = q/html_arr.query([in_str,"i"],1)/;
    $x[$i] = {
       'val' => bag(
         'Meet Jack',
         'My tech stock picks',
         'NAME',
         'SYMBOL',
         'CURRENT',
         '52WK HI',
         '52WK LO',
         'P/E RATIO',
         'look',
         'little'
       ),
       'type' => 'array'
    };
    $d[$i] = 0;
    $i++;
} else {
    $logger->debug("Skipped tests based upon: ",$turl);   
}

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

my $perl_version = $^V;
if (! $perl_version) {
    diag "WTF? Where do you even find a version of perl this old?";
} elsif ($perl_version lt v5.10) {
    diag "Using perl version $perl_version, skipping super-cool REGEXP test!";
} else {
    $e[$i] = q#mail2_str.extract(re/\s*\*\s*([ \w]+)\s*\v\s*\*\s*([ \w]+)\v/)#;
    $x[$i] = {
       'val' => ['Select an orthopedic surgeon','Set an appointment for a consultation'],
       'type' => 'array'
    };
    $d[$i]  = 0;
    $i++;
}

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


#-------------------------------------------------------------------------------------
# encode()/decode()
#-------------------------------------------------------------------------------------

$e[$i] = q/my_jstr.decode()/;
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

$e[$i] = q/my_jstr.decode().pick("$..text")/;
$x[$i] = {
    "val" => "AAA members save money!",
    "type" => "str"
};
$d[$i] = 0;
$i++;

#newparser format

diag("Okay to ignore JSON parse error");
$e[$i] = q/bad_jstr.decode()/;
# format's important in this since we're not comparing with no whitespace
$x[$i] = {
    "val" => {
     'error' => [
       '
    "www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]}
'
     ]
   },
    "type" => "hash"
};
$d[$i] = 0;
$i++;

$e[$i] = q/i_h.encode()/;
$x[$i] = {
    'val' => '{"mKey":"mValue","hKey":{"innerKey":"innerVal"}}',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/c_h.encode()/;
$x[$i] ={
    'val' => '[{"hKey":"hValue"}]',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/d_h.encode()/;
$x[$i] ={
    'val' => '[{"hKey":"hValue"},{"mKey":"mValue"}]',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/a_h.encode()/;
$x[$i] = {
    'val' => '{"pi as array":[3,1,4,1,5,6,9],"colors of the wind":"many"}',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

##en
$e[$i] = q/simple_map.encode()/;
$x[$i] = {
    'val' => '{"test":80,"foo":100}',
    'type' => 'str'
};
$d[$i] = 0;
$i++;

$e[$i] = q/simple_a_of_a.encode()/;
$x[$i] = {
    'val' => '[["test",80],["foo",100]]',
    'type' => 'str'
};
$d[$i] = 0;
$i++;



# New pick argument to retain array

$e[$i] = q/store.pick("$..book[0].price",1)/;
$x[$i] = {'val' => ['8.95'],
      'type' => 'array'};
$d[$i]  = 0;
$i++;

$e[$i] = q/store.pick("$..book[1].price")/;
$x[$i] = {'val' => '12.99',
      'type' => 'num'};
$d[$i]  = 0;
$i++;


$e[$i] = q#phone_num.replace(re/([0-9]{3}).*/,"$1")#;
$x[$i] = {
   'val' => '123',
   'type' => 'num'
};
$d[$i]  = 0;
$i++;



# hash operations

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


$e[$i] = q/a_h.put(a_path,foo)/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => 'I like cheese'
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/a_h.put(b_path,foo)/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => {
	  	'bar' => 'I like cheese'
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/a_h.put(c_path,foo)/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => {
	  	'bar' => {
	  		10 => 'I like cheese'
	  	}
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;


$e[$i] = q/i_h.put(d_path,"REPLACED")/;
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

$e[$i] = q/j_h.put(["foo","bar"],"REPLACED")/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => {
	  	'bar' => 'REPLACED'
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.put(b_path,"REPLACED")/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => {
	  	'bar' => 'REPLACED'
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.delete(b_path)/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => {
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.delete(["foo","bar",10])/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'colors of the wind' => 'many',
	  'foo' => {
	  	'bar' => {}
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.delete(["colors of the wind"])/;
$x[$i] = {
	'val' => {
	  'pi as array' => [
	    3,
	    1,
	    4,
	    1,
	    5,
	    6,
	    9
	  ],
	  'foo' => {
	  	'bar' => {
	  		10 => 'I like cheese'
	  	}
	  }
	},
	'type'=>'hash'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.keys()/;
$x[$i] = {
	'val' => [
	  'pi as array',
	  'colors of the wind',
	  'foo',
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.keys("foo")/;
$x[$i] = {
	'val' => [
	  'bar',
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.keys(["foo"])/;
$x[$i] = {
	'val' => [
	  'bar',
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

# $e[$i] = q/j_h.keys().head()/;
# $x[$i] = {
# 	'val' => 'pi as array',
# 	'type'=>'str'
# };
# $d[$i] = 0;
# $i++;

# $e[$i] = q/j_h{j_h.keys().head()}/;
# $x[$i] = {
# 	'val' => [3,1,4,1,5,6,9],
# 	'type'=>'array'
# };
# $d[$i] = 0;
# $i++;



$e[$i] = q/k_h.keys()/;
$x[$i] = {
	'val' => [
	  '1',
	  '3',
	  '2'
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/store.keys(["store"])/;
$x[$i] = {
	'val' => [
	  'bicycle',
	  'book'
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/store.keys(["store","bicycle"])/;
$x[$i] = {
	'val' => [
	  'color',
	  'price'
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/k_h.keys([1,"A"])/;
$x[$i] = {
	'val' => [
	  'a',
	  'b'
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/k_h.keys([2])/;
$x[$i] = {
	'val' => [],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

## values

$e[$i] = q/j_h.values()/;
$x[$i] = {
	'val' => [[3,1,4,1,5,6,9],
		  "many",
		  {"bar" => {10 =>"I like cheese"}}
		 ],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.values("foo")/;
$x[$i] = {
	'val' => [
	  {10 => "I like cheese"}
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/j_h.values(["foo"])/;
$x[$i] = {
	'val' => [
	  {10 => "I like cheese"}
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

# $e[$i] = q/j_h.values().head()/;
# $x[$i] = {
# 	'val' => 'pi as array',
# 	'type'=>'str'
# };
# $d[$i] = 0;
# $i++;

# $e[$i] = q/j_h{j_h.values().head()}/;
# $x[$i] = {
# 	'val' => [3,1,4,1,5,6,9],
# 	'type'=>'array'
# };
# $d[$i] = 0;
# $i++;



$e[$i] = q/k_h.values()/;
$x[$i] = {
	'val' => [
		  {"A" => {"a" => "1Aa","b"=>"1Ab"}},
		  {"snicker" => "snee", "7" => 5},
		  "qwerty",
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/store.values(["store","bicycle"])/;
$x[$i] = {
	'val' => [
		  "red",
		  19.95
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/k_h.values([1,"A"])/;
$x[$i] = {
	'val' => [
	  '1Aa',
	  '1Ab'
	],
	'type'=>'array'
};
$d[$i] = 0;
$i++;

$e[$i] = q/k_h.values([2])/;
$x[$i] = {
	'val' => [],
	'type'=>'array'
};
$d[$i] = 0;
$i++;



##
## klog
##
$e[$i] = q#c.reverse().klog("Value of reversed array: ").join(";")#;
$x[$i] = {
   'val' => "6;5;4",
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#c.reverse().join(";").klog("Value of reversed array: ")#;
$x[$i] = {
   'val' => "6;5;4",
   'type' => 'str'
};
$d[$i]  = 0;
$i++;

##
## slice
##
$e[$i] = q#g_s.slice(1,4)#;
$x[$i] = {
   'val' => ['tomato','tomato','tomato','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.slice(2)#;
$x[$i] = {
   'val' => ['corn','tomato','tomato'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.slice(14)#;
$x[$i] = undef;
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.slice(0,0)#;
$x[$i] = {
   'val' => ['corn'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

##
## splice
##


  # a_s = ['apple','pear','orange','tomato'];
  # b_s = ['string bean','corn','carrot','tomato','spinach'];
  # c_s = ['wheat','barley','corn','rice'];
  # d_s = ['','pear','corn'];
  # e_s = '';
  # f_s = ['corn','tomato'];
  # g_s = ['corn','tomato','tomato','tomato','sprouts','lettuce','sprouts'];


$e[$i] = q#g_s.splice(1,4)#;
$x[$i] = {
   'val' => ['corn','lettuce','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.splice(2,0,f_s)#;
$x[$i] = {
   'val' => ['corn','tomato','corn','tomato','tomato','tomato','sprouts','lettuce','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.splice(2,0,'liver')#;
$x[$i] = {
   'val' => ['corn','tomato','liver','tomato','tomato','sprouts','lettuce','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.splice(2,2,f_s)#;
$x[$i] = {
   'val' => ['corn','tomato','corn','tomato','sprouts','lettuce','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.splice(2,3,f_s)#;
$x[$i] = {
   'val' => ['corn','tomato','corn','tomato','lettuce','sprouts'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.splice(2,10)#;
$x[$i] = {
   'val' => ['corn','tomato'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

$e[$i] = q#g_s.splice(2,10,f_s)#;
$x[$i] = {
   'val' => ['corn','tomato','corn','tomato'],
   'type' => 'array'
};
$d[$i]  = 0;
$i++;

ENDY:



# now run the tests....
my $l = scalar @e;
plan tests => $l+6; # bump for persistent tests below that run after these

my $j;
for ($j = 0; $j < $i; $j++) {
    test_operator($e[$j], $x[$j], $d[$j]);
}


#---------- set persistent ----------
my ($v, $r, $p, $x);

$e[$i] = q#a.pset(ent:foo)#;
$v = Kynetx::Parser::parse_expr($e[$i]);
#diag Dumper $v;
$p = $v->{"args"}->[0];
Kynetx::Persistence::delete_persistent_var($p->{"domain"}, $rid, $session, $p->{"name"});

$r = eval_expr($p, $rule_env, $rule_name,$req_info, $session);
$x = {
   'val' => 0,
   'type' => 'num'
};
#diag Dumper $r;
cmp_deeply($r, $x, "Ensure persistent is cleared");   

$x[$i] = {
   'val' => 10,
   'type' => 'num'
};
$d[$i]  = 0;
test_operator($e[$i], $x[$i], $d[$i]);

# test persistent is OK


$r = eval_expr($p, $rule_env, $rule_name,$req_info, $session);
cmp_deeply($r, $x[$i], "Ensure persistent is set");   
#diag Dumper $r;

$i+=3;


#---------- set persistent hash ----------
my ($v, $r, $p, $x);

#diag "---------------------- persistent hash ----------------";
$e[$i] = q#a.pset(ent:foo{["flip"]})#;
$v = Kynetx::Parser::parse_expr($e[$i]);
#diag Dumper $v;
$p = $v->{"args"}->[0];
my $path_r = $p->{'hash_key'};
my $path = Kynetx::Util::normalize_path($req_info, $rule_env, $rule_name, $session, $path_r);

Kynetx::Persistence::delete_persistent_hash_element($p->{"domain"}, $rid, $session, $p->{"name"}, $path);

$r = eval_expr($p, $rule_env, $rule_name,$req_info, $session);
$x = {
   'val' => undef,
   'type' => "null"
};
#diag Dumper $r;
cmp_deeply($r, $x, "Ensure persistent is cleared");   

$x[$i] = {
   'val' => 10,
   'type' => 'num'
};
$d[$i]  = 0;
test_operator($e[$i], $x[$i], $d[$i]);

# test persistent is OK


$r = eval_expr($p, $rule_env, $rule_name,$req_info, $session);
cmp_deeply($r, $x[$i], "Ensure persistent is set");   
#diag Dumper $r;

$i+=3;




1;

