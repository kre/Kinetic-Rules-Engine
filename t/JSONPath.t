#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use JSON::XS;
use Data::Dumper;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::JSONPath qw/:all/;
use Kynetx::JavaScript qw/:all/;



$Data::Dumper::Indent = 1;


my %test_structure =(
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
);

plan tests => 70;


my $jp = Kynetx::JSONPath->new();
my $raw_result;
my @result;
my $expected;


$raw_result = $jp->run(\%test_structure, '$.store.book[0]');
isnt($raw_result, 0);
@result = @{$raw_result};
$expected = [
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
    }
];
is_deeply($raw_result, $expected);


$raw_result = $jp->run(\%test_structure, '$.store.book[1]');
isnt($raw_result, 0);
@result = @{$raw_result};
$expected = [
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
    }
];
is_deeply($raw_result, $expected);


$raw_result = $jp->run(\%test_structure, '$.store.book[*].author');
isnt($raw_result, 0, '$.store.book[*].author not empty');
@result = @{$raw_result};
is($#result, 3, '$.store.book[*].author gives back 3 authors');


$raw_result = $jp->run(\%test_structure, '$..author');
isnt($raw_result, 0, '$..author not empty');
@result = @{$raw_result};
is($#result, 3, '$..author gives back 3 authors');

$raw_result = $jp->run(\%test_structure, '$..book[?(@.price<10)]');
$expected = decode_json(
'[
 {"category":"reference", 
  "ratings" : [1, 3, 2, 10 ],
"author":"Nigel Rees", "title":"Sayings of the Century", "price":8.95}, 
 {"category":"fiction", "author":"Herman Melville", "title":"Moby Dick", "isbn":"0-553-21311-3", "price":8.99}
]');
isnt($raw_result, 0, '$..book[?(@.price<10)] not empty');
#diag Dumper($raw_result);
@result = @{$raw_result};
is($#result, 1, '$..book[?(@.price<10)] of length 1');
is_deeply($raw_result, $expected);
# foreach my $book_map (@result){ # order isn't guaranteed
#     ok(defined $book_map->{'category'});
#     ok(defined $book_map->{'author'});
#     ok(defined $book_map->{'title'});
#     ok(defined $book_map->{'price'});
#     if (defined $book_map->{'isbn'}){
# 	# moby dick
# 	is($book_map->{'price'}, 8.99);
# 	is($book_map->{'title'}, 'Moby Dick');
#     } else {
# 	#sayings of the century
# 	is($book_map->{'price'}, 8.95);
# 	is($book_map->{'title'}, 'Sayings of the Century');
#     }
# }


$raw_result = $jp->run(\%test_structure, '$..book[?(@.price == 8.99)]');
$expected = decode_json('[
 {"category":"fiction", "author":"Herman Melville", "title":"Moby Dick", "isbn":"0-553-21311-3", "price":8.99}
]');
isnt($raw_result, 0, '$..book[?(@.price == 8.99)] not empty');
@result = @{$raw_result};
is($#result, 0, '$..book[?(@.price == 8.99)] of length 0');
is_deeply($raw_result, $expected);


$raw_result = $jp->run(\%test_structure, '$..book[?(@.price != 8.99)]');
isnt($raw_result, 0, '$..book[?(@.price != 8.99)] not empty');
@result = @{$raw_result};
is($#result, 2, '$..book[?(@.price != 8.99)] of length 2');


$raw_result = $jp->run(\%test_structure, '$..book[?(@.title eq "Moby Dick")]');
$expected = decode_json('[
 {"category":"fiction", "author":"Herman Melville", "title":"Moby Dick", "isbn":"0-553-21311-3", "price":8.99}
]');
isnt($raw_result, 0, 'not empty');
@result = @{$raw_result};
is($#result, 0, 'length 0');
is_deeply($raw_result, $expected);

$raw_result = $jp->run(\%test_structure, '$..book[?(@.title ne "Moby Dick")]');
isnt($raw_result, 0, 'not empty');
@result = @{$raw_result};
is($#result, 2, 'length 2');



$raw_result = $jp->run(\%test_structure, '$.store.*'); #book array and one bicycle
isnt($raw_result,0);
@result = @{$raw_result};
is($#result, 1);


$raw_result = $jp->run(\%test_structure, '$.store..price'); #the price of everything
isnt($raw_result,0);
@result = @{$raw_result};
is($#result,4);
my %prices = (
    19.95 => 1,
    8.95 => 1,
    12.99 => 1,
    8.99 => 1,
    22.99 => 1
    );
foreach my $price (@result){
    ok(exists $prices{$price});
}
	
$raw_result = $jp->run(\%test_structure, '$..book[0,1]'); # the first two books
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result,1);
like($raw_result->[0]->{'category'}, qr/reference|fiction/);
like($raw_result->[1]->{'category'}, qr/reference|fiction/);


$raw_result = $jp->run(\%test_structure, '$..book[:2]'); # the first two books
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 1);
like($raw_result->[0]->{'category'}, qr/reference|fiction/);
like($raw_result->[1]->{'category'}, qr/reference|fiction/);


$raw_result = $jp->run(\%test_structure, '$..book[-1:]'); # the last book
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 0);
like($raw_result->[0]->{'isbn'}, qr/0-395-19395-8/);

$raw_result = $jp->run(\%test_structure, '$..book[?(@.isbn)]'); # every book with an ISBN
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 1);
foreach my $book (@result){
    is($book->{'category'}, 'fiction');
}

$raw_result = $jp->run(\%test_structure, '$.store.!'); #the keys in the store hash 
isnt($raw_result,0);
@result = @{$raw_result};
is($#result, 1);
is_deeply($raw_result, ['bicycle','book']);


# testing paths.  KCode doesn't use this, but since it's there we'll test
$raw_result = $jp->run(\%test_structure, '$..author', {'result_type' => 'PATH'});
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 3);
is($result[0], "[\"store\"][\"book\"][0][\"author\"]");
is($result[1], "[\"store\"][\"book\"][1][\"author\"]");
is($result[2], "[\"store\"][\"book\"][2][\"author\"]");
is($result[3], "[\"store\"][\"book\"][3][\"author\"]");

$raw_result = $jp->run(\%test_structure, '$.store.!', {'result_type' => 'PATH'});
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 1);
is($result[0], "[\"store\"]");
is($result[1], "[\"store\"]");

# includes
$raw_result = $jp->run(\%test_structure, '$..book[?(@.ratings><"good")]');
$expected = decode_json('[
   {
      "ratings" : [
         "good",
         "bad",
         "lovely"
      ],
      "category" : "fiction",
      "author" : "Evelyn Waugh",
      "title" : "Sword of Honour",
      "price" : 12.99
   }
]'
);
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 0);
is_deeply($raw_result, $expected);

#diag "Starting with ratings...";
$raw_result = $jp->run(\%test_structure, "\$..ratings[?(@.><'good')]");
$expected = decode_json(
'[
   [
      "good",
      "bad",
      "lovely"
   ]
]'
);
#diag Dumper($raw_result);
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 0);
is_deeply($raw_result,$expected);

#diag "Numerci ratings...";
$raw_result = $jp->run(\%test_structure, "\$..ratings[?(@.><3)]");
$expected = decode_json(
'[
  [
         1,
         3,
         2,
        10
      ]
]'
);
#diag Dumper($raw_result);
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 0);
is_deeply($raw_result,$expected);

$raw_result = $jp->run(\%test_structure, "\$..book[?(@.ratings><3)]");
$expected = decode_json(
'[
   {
      "ratings" : [
         1,
         3,
         2,
        10
      ],
      "category" : "reference",
      "author" : "Nigel Rees",
      "title" : "Sayings of the Century",
      "price" : 8.95
   }
]'
);
isnt($raw_result, 0);
@result = @{$raw_result};
is($#result, 0);
#diag Dumper($raw_result);
#is($result[0]{'category'}, 'reference');
is_deeply($raw_result,$expected);



1;


