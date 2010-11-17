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
use Test::Deep;
use Data::Dumper;
use MongoDB;
use Apache::Session::Memcached;
use DateTime;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
#use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::Application qw/:all/;
my $logger = get_logger();
my $num_tests = 0;
my $result;

# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $r = new Kynetx::FakeReq();
my $oid_re = qr([0-9|a-f]{16});

# Rule stuff
my $fkan = 93402939302;
my $k1024 = "4c7d71a167458b950b000000";
my $ka144 = "4c61e016ab900dc2f8aab2ce";
my $rnd1 = int(rand(200));
my $rnd2 = int(rand(100));
my $rid1 = "1024";
my $rid2 = "a144x22";
my $ridR = "test".$rnd1."x".$rnd2;

# get random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $key1 = $DICTIONARY[rand(@DICTIONARY)];
my $key2 = $DICTIONARY[rand(@DICTIONARY)];
my $key3 = $DICTIONARY[rand(@DICTIONARY)];
chomp($key1);
chomp($key2);
chomp($key3);

# basic Application getter/setter
$result = Kynetx::Persistence::Application::put($rid1,$key1,$key2);
testit($result,1,"Insert data for $rid1",0);

$result = Kynetx::Persistence::Application::get($rid1,$key1);
testit($result,$key2,"Retrieve data for $rid1/$key1",0);

$result = Kynetx::Persistence::Application::get_created($rid1,$key1);
testit($result,re(qr/\d+/),"Retrieve timestamp for $rid1/$key1",0);

$result = Kynetx::Persistence::Application::delete($rid1,$key1);
testit($result,'',"Delete data for $rid1/$key1",0);

$result = Kynetx::Persistence::Application::get($rid1,$key1);
testit($result,undef,"Retrieve data for deleted $rid1/$key1",0);

# Store to a new ruleset
$result = Kynetx::Persistence::Application::put($ridR,$key1,$key3);
testit($result,1,"Insert to new store $ridR",0);

$result = Kynetx::Persistence::Application::get($ridR,$key1);
testit($result,$key3,"Retrieve data for $ridR/$key1",0);

$result = Kynetx::Persistence::Application::delete($ridR,$key1);
testit($result,'',"delete data for $ridR/$key1",0);

$result = Kynetx::Persistence::Application::get($ridR,$key1);
testit($result,undef,"Retrieve data for deleted $ridR/$key1",0);

$result = Kynetx::Persistence::Application::touch($ridR,$key3);
testit($result,0,"Touch a new variable ($key3)",0);

$result = Kynetx::Persistence::Application::delete($ridR,$key3);
testit($result,'',"delete data for $key3",0);

sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    cmp_deeply($got,$expected,$description);
}

plan tests => $num_tests;
1;