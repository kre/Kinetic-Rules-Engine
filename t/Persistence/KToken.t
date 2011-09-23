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

use Test::More;
use Test::Deep;
use Data::Dumper;
use MongoDB;
use Apache::Session::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

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
my $session_id = Kynetx::Session::session_id($session);

#diag "session: ", $session_id;
my $description;
my $token;
my $tokenb;
my $ts1;
my $ts2;

my $org_token = Kynetx::MongoDB::delete_value("tokens",{'endpoint_id' => $session_id});
$logger->debug("Original: ", sub {Dumper($org_token)});

$description = "No token in session";
$token = Kynetx::Persistence::KToken::get_token($session,$rid);
testit($token,undef,$description,0);


$description = "Token is created";
$token = Kynetx::Persistence::KToken::new_token($rid,$session,$ken);
testit($token,re($tok_re),$description,0);

my $key = {
  "ktoken" => $token
};
my $got = Kynetx::MongoDB::get_value("tokens",$key);
$ts1 = $got->{"last_active"};
#diag "Token last accessed: $ts1";

$description = "Check that token is valid";
$result = Kynetx::Persistence::KToken::is_valid_token($token,$session_id);
testit($result->{"last_active"},$ts1,$description,0);

$description = "Check token from session";
$tokenb = Kynetx::Persistence::KToken::get_token($session,$rid);
testit($token,$tokenb->{'ktoken'},$description,0);

$description = "Delete the token, check Mongo";
Kynetx::Persistence::KToken::delete_token($token);
$got = Kynetx::MongoDB::get_value("tokens",$key);
testit($got,undef,$description);

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