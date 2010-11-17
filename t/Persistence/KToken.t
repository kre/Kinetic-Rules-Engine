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

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::KToken qw/:all/;
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

my $ken_re = qr([0-9|a-f]{16});
my $tok_re = qr([A-Za-z0-9+/]{44});

my $r = new Kynetx::FakeReq();
my $rid = "token_tests";
my $ken = "4c6484f5a1a31171365896f4";

my $session = process_session($r);
my $description;
my $token;
my $tokenb;
my $ts1;
my $ts2;

## Clean things up
$token = Kynetx::Persistence::KToken::session_has_token($session,$rid);
if ($token) {
    Kynetx::Persistence::KToken::delete_token($token);
}

$description = "No token in session";
$token = Kynetx::Persistence::KToken::session_has_token($session,$rid);
testit($token,undef,$description,1);

$description = "Token is created";
$token = Kynetx::Persistence::KToken::new_token($rid,$ken);
testit($token,re($tok_re),$description,1);

my $key = {
  "ktoken" => $token
};
my $got = Kynetx::MongoDB::get_value("tokens",$key);
$ts1 = $got->{"last_active"};

$description = "Check that token is valid";
$result = Kynetx::Persistence::KToken::is_valid_token($token,$rid);
testit($result,1,$description,1);

$description = "Save token to Apache session";
$tokenb = Kynetx::Persistence::KToken::store_token_to_apache_session($token,$rid,$session);
testit($tokenb,$token,$description,1);

$description = "Check token from session";
$tokenb = Kynetx::Persistence::KToken::session_has_token($session,$rid);
testit($token,$tokenb,$description,1);

diag "Pause for 1 second";
sleep 1;

$description = "Check that token *last_active* is updated";
my $tokenc = Kynetx::Persistence::KToken::get_token($token,$rid);
$got = Kynetx::MongoDB::get_value("tokens",$key);
$ts2 = $got->{"last_active"};
testit(1,bool($ts2 > $ts1),$description);


$description = "Delete the token";
Kynetx::Persistence::KToken::delete_token($token);
$got = Kynetx::MongoDB::get_value("tokens",$key);
testit($got,{},$description);

$logger->debug("After delete: ", sub { Dumper($got)});

sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    cmp_deeply($got,$expected,$description);
}

session_cleanup($session);

plan tests => $num_tests;
1;