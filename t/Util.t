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

use Test::More;

use Test::LongString;
use Test::Deep;
use Apache::Session::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::FakeReq;
use DateTime;
use Data::Dumper;


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
my $logger = get_logger();

# before_now
my $after = DateTime->now->add( days => 1 );
my $before = DateTime->now->add( days => -1 );

#diag("Now $now");
#diag("Before $before");
#diag("After $after");

my $num_test = 7;

ok(before_now($before), "before_now: before");
ok(!before_now($after), "before_now: after");

# after_now
ok(after_now($after), "after_now: after");
ok(!after_now($before), "after_now: before");


my $url = 'http://www.windley.com/?';

my $url_options = {'A' => '1',
		   'B' => '2',
		   'C' => 'This is a test',
		  };


is(mk_url($url, $url_options), "http://www.windley.com/?A=1&C=This%20is%20a%20test&B=2");

$url = 'http://www.windley.com/';

$url_options = {'A' => '1',
		   'B' => '2',
		   'C' => 'This is a test',
		  };


is(mk_url($url, $url_options), "http://www.windley.com/?A=1&C=This%20is%20a%20test&B=2");

$url = 'http://www.windley.com/?A=1';

$url_options = {'B' => '2',
		'C' => 'This is a test',
	       };


is(mk_url($url, $url_options), "http://www.windley.com/?A=1&C=This%20is%20a%20test&B=2");


my $description = "Hash: h/1 w/2";

my $test_hash =  {
	'a' => 12,
	'b' => 3
};
my $expected = [
  {
    'value' => 12,
    'ancestors' => [
      'a'
    ]
  },
  {
    'value' => 3,
    'ancestors' => [
      'b'
    ]
  }
];

my $result = Kynetx::Util::hash_to_elements($test_hash);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($expected,$result,$description);
$num_test++;

$result = Kynetx::Util::elements_to_hash($expected);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($test_hash,$result,$description);
$num_test++;

$description = "Hash: h/1 w/2";
$test_hash =  {
	'a' => '1.1',
	'b' => {
		'c' => '2.1'
	},
	'd' =>'1.3'
};
$expected = [
  {
    'value' => '1.1',
    'ancestors' => [
      'a'
    ]
  },
  {
    'value' => '2.1',
    'ancestors' => [
      'b',
      'c'
    ]
  },
  {
    'value' => '1.3',
    'ancestors' => [
      'd'
    ]
  }
];
$result = Kynetx::Util::hash_to_elements($test_hash);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($expected,$result,$description);
$num_test++;

$result = Kynetx::Util::elements_to_hash($expected);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($test_hash,$result,$description);
$num_test++;

$description = "Hash: h/1 array";

$test_hash =  {
	'a' => ['a1','a2','a3']
};
$expected = [
  {
    'value' => ['a1','a2','a3'],
    'ancestors' => [
      'a'
    ]
  }
];
$result = Kynetx::Util::hash_to_elements($test_hash);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($expected,$result,$description);
$num_test++;

$result = Kynetx::Util::elements_to_hash($expected);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($test_hash,$result,$description);
$num_test++;

$description = "Hash: h/1 w/2";

$test_hash =  {
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
};

$expected = [
  {
    'value' => '1.1',
    'ancestors' => [
      'a'
    ]
  },
  {
    'value' => '2.2',
    'ancestors' => [
      'b',
      'e'
    ]
  },
  {
    'value' => '2.1',
    'ancestors' => [
      'b',
      'c'
    ]
  },
  {
    'value' => 5,
    'ancestors' => [
      'b',
      'f',
      'h'
    ]
  },
  {
    'value' => [
      '3.a',
      '3.b',
      '3.c',
      '3.d'
    ],
    'ancestors' => [
      'b',
      'f',
      'g'
    ]
  },
  {
    'value' => '1.3',
    'ancestors' => [
      'd'
    ]
  }
];
$result = Kynetx::Util::hash_to_elements($test_hash);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($expected,$result,$description);
$num_test++;


$test_hash =  {
	'a' => 12,
};
$expected = [
  {
    'value' => 12,
    'ancestors' => [
      'a'
    ]
  }
];

#Log::Log4perl->easy_init($DEBUG);

$result = Kynetx::Util::hash_to_elements($test_hash);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($expected,$result,$description);
$num_test++;

$result = Kynetx::Util::elements_to_hash($expected);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($test_hash,$result,$description);
$num_test++;

my $tricky_hash = {
	'a' => 1.1,
	'b' => [
		'c' => 2,
		'e' => 3,
		'f' => {
			'g' => 4,
			'h' => [4, 6, 7]
		}
	],
};

$expected = [
  {
    'value' => '1.1',
    'ancestors' => [
      'a'
    ]
  },
  {
    'value' => [
      'c',
      2,
      'e',
      3,
      'f',
      {
        'h' => [
          4,
          6,
          7
        ],
        'g' => 4
      }
    ],
    'ancestors' => [
      'b'
    ]
  }
];

$result = Kynetx::Util::hash_to_elements($tricky_hash);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($result,$expected,$description);
$num_test++;

$result = Kynetx::Util::elements_to_hash($result);
$logger->debug("R: ", sub {Dumper($result)});
cmp_deeply($result,$tricky_hash,$description);
$num_test++;


done_testing($num_test);

1;


