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
use warnings;

use Test::More;
use Test::LongString;
use Test::Deep;
use Test::WWW::Mechanize;
use Cache::Memcached;
use Data::UUID;

use Socket;


use Kynetx::Configure qw/:all/;
use Kynetx::Test qw/:all :vars/;
use Kynetx::FakeReq qw/:all/;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

############### Session/Request config
my $r = Kynetx::Test::configure();
my $rid = 'cs_test';
my $rule_name = "n-star";
my $my_req_info = Kynetx::Test::gen_req_info($rid);
my $rule_env = Kynetx::Test::gen_rule_env();
my $session = Kynetx::Test::gen_session($r, $rid);
my $session_ken = Kynetx::Persistence::KEN::get_ken($session,"null");
my $test_count = 0;


############### User/Developer config
$platform = Kynetx::Test::platform();
$root_env= Kynetx::Test::gen_root_env($my_req_info,$rule_env,$session);
$username = Kynetx::Test::rword();
#$user_ken = Kynetx::Test::gen_user($my_req_info,$root_env,$session,$username);
#$user_eci = Kynetx::Persistence::KToken::get_oldest_token($user_ken);

############### Testing
my ($cloudnumber,$ug);
$ug = new Data::UUID;
$cloudnumber = $ug->create_str();

$description = "Create a Neustar style account";
$args = {
  "cloudnumber" => $cloudnumber
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$root_env,$session,$rule_name,"foo",[$args]);
isnt($result,undef,$description);
$test_count++;

$user_eci = $result->{'cid'};
$user_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($user_eci);

$description = "ECI points to valid KEN";
isnt($user_ken,undef,$description);
$test_count++;

$description = "Check for username exists (true)";
$args = $cloudnumber;
$result = Kynetx::Modules::PCI::check_username($my_req_info,$root_env,$session,$rule_name,"foo",[$args]);
is($result,1,$description);
$test_count++;


$description = "Get the cloudnumber from the ECI";
$args = $user_eci;
$result = Kynetx::Modules::PCI::get_account_username($my_req_info,$root_env,$session,$rule_name,"foo",[$args]);
is($result,$cloudnumber,$description);
$test_count++;

############### User/Developer config
Kynetx::Test::flush_test_user($user_ken,$cloudnumber);

done_testing($test_count);

1;


