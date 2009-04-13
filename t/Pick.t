#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
use Data::Dumper;

use Kynetx::Test qw/:all/;
use Kynetx::Pick qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::JavaScript qw/:all/;



$Data::Dumper::Indent = 1;



my $req_info;
$req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$req_info->{'pool'} = APR::Pool->new;

my $rule_name = 'foo';

my $rule_env = {$rule_name . ':a' => '10',
		$rule_name . ':b' => '11'
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





my (@e, @x, @d);


sub test_pick {
    my ($e, $x, $d) = @_;

    my ($v, $r);

    $v = Kynetx::Parser::parse_expr($e);

    $r = eval_js_expr($v, $rule_env, $rule_name,$req_info);
    diag Dumper($r) if $d;
    is_deeply($r, $x, "Trying $e");
}

$e[0] = q/store.pick("$.store.book[*].author")/;
$x[0] = {
   'val' => [
     'Nigel Rees',
     'Evelyn Waugh',
     'Herman Melville',
     'J. R. R. Tolkien'
   ],
   'type' => 'array'
};

$e[1] = q/store.pick("$..author")/;
$x[1] = {
   'val' => [
     'Nigel Rees',
     'Evelyn Waugh',
     'Herman Melville',
     'J. R. R. Tolkien'
   ],
   'type' => 'array'
};

$e[2] = q/store.pick("$..book[?(@.price<10)]")/;
$x[2] = {
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


$e[3] = q/store.pick("$..book[?(@.price == 8.99)]")/;
$x[3] = {
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
$d[3]  = 0;


$e[4] = q/store.pick("$..book[?(@.price == 8.99)]")/;
$x[4] = {
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
$d[4]  = 0;


$e[5] = q/store.pick("$..book[?(@.price != 8.99)]")/;
$x[5] = {
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
$d[5]  = 0;

$e[6] = q/store.pick("$..book[?(@.title eq 'Moby Dick')]")/;
$x[6] = {
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
$d[6]  = 0;

$e[7] = q/store.pick("$..book[?(@.title ne 'Moby Dick')]")/;
$x[7] = {
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
$d[7]  = 0;

$e[8] = q/store.pick("$.store..price")/;
$x[8] = {
'val' => [
     '19.95',
     '8.95',
     '12.99',
     '8.99',
     '22.99'
   ],
   'type' => 'array'
};
$d[8]  = 0;

$e[9] = q/store.pick("$..book[0,1]")/;
$x[9] = {
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
$d[9]  = 0;

$e[10] = q/store.pick("$..book[0].price") + a/;
$x[10] = {'val' => '18.95',
	  'type' => 'num'};
$d[10]  = 0;

$e[11] = q/b + store.pick("$..book[1].price")/;
$x[11] = {'val' => '23.99',
	  'type' => 'num'};
$d[11]  = 0;


# now run the tests....
my $l = scalar @e;
plan tests => $l;

my $i;
for ($i = 0; $i < $l; $i++) {
    test_pick($e[$i], $x[$i], $d[$i]);
}


1;


