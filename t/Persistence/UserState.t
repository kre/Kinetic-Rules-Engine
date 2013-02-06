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
#use warnings;
#use diagnostics;

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Events::State qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Events::Primitives qw/:all/;
use Kynetx::Persistence::UserState qw/:all/;
use Kynetx::Persistence::Ruleset qw/:all/;


use Kynetx::FakeReq qw/:all/;

my $logger = get_logger();

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $test_count = 0;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $mystate = "foobarbean";
my $result;
$result = Kynetx::Persistence::UserState::reset_event_env($rid,$session);
$result = Kynetx::Persistence::UserState::reset_group_counter($rid,$session,$rule_name,$mystate);

$result = Kynetx::Persistence::UserState::push_aggregator($rid,$session,$rule_name,$mystate,1);

$logger->debug("Inc'd: ", sub {Dumper($result)});

cmp_deeply(scalar (@{$result->{$mystate}}),1,'Increment a group state from empty env');
$test_count++;


$result = Kynetx::Persistence::UserState::push_aggregator($rid,$session,$rule_name,$mystate,2);
$result = Kynetx::Persistence::UserState::push_aggregator($rid,$session,$rule_name,$mystate,3);
cmp_deeply(scalar (@{$result->{$mystate}}),3,'Incremented 3 times');
$test_count++;


$result = Kynetx::Persistence::UserState::reset_group_counter($rid,$session,$rule_name,$mystate);
$logger->info("state: ", sub {Dumper($result)});
cmp_deeply(scalar (@{$result->{$mystate}}),0,'State count reset');
$test_count++;

done_testing($test_count);

1;


