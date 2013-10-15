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
use DateTime;
use Benchmark ':hireswallclock';
use DateTime::Format::ISO8601;
use DateTime::Format::RFC3339;

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
use Kynetx::Persistence::SchedEv qw/:all/;
use Kynetx::Predicates::Time qw/:all/;
use Kynetx::Modules::Event;

my $logger = get_logger();
my $num_tests = 0;
my $result;
my ($start,$end,$qtime);
my $num_events = 0;

# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $r = new Kynetx::FakeReq();
my $oid_re = qr([0-9|a-f]{16});
my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $uname = $DICTIONARY[rand(@DICTIONARY)];
chomp($uname);

my $ename = $DICTIONARY[rand(@DICTIONARY)];
chomp($ename);

my $rid = 'schedev_test';
my $my_req_info = Kynetx::Test::gen_req_info($rid);
my $rule_env = Kynetx::Test::gen_rule_env();
my $session = Kynetx::Test::gen_session($r, $rid);
my $now = Kynetx::Predicates::Time::now();
my $plusDay = Kynetx::Predicates::Time::add($my_req_info,"foo",[$now,{days => 1}]);
my $plusFive = Kynetx::Predicates::Time::add($my_req_info,"foo",[$now,{hours => 5}]);
my $lessYear = Kynetx::Predicates::Time::add($my_req_info,"foo",[$now,{years => -1}]);

# Fake User
my $user_ken = Kynetx::Test::gen_user($my_req_info,$rule_env,$session,$uname);

my $domain;
my $eventname;
my $timespec;
my $attr;

# new_scheduled_event
my $r_min = int (rand(59));
my $description = "Create a new recurring event";
$domain = "notification";
$eventname = $ename;
$attr->{'timezone'} = 'America/Denver';
$timespec = "$r_min * * * *";
my $sched_id = Kynetx::Persistence::SchedEv::repeating_event($user_ken,$rid,$domain,$eventname,$timespec,$attr);
isnt($sched_id,undef,$description);
$num_tests++;
$logger->debug("SchedEv: $sched_id");
$num_events++;

$description = "Check that event is saved to database";
my $schedEv = Kynetx::Persistence::SchedEv::get_sched_ev($sched_id);
is($schedEv->{'_id'},$sched_id,$description);
$num_tests++;
$logger->debug("SchedEv: ",sub {Dumper($schedEv)});

$description = "Single Event";
$timespec = $now;
$sched_id = Kynetx::Persistence::SchedEv::single_event($user_ken,$rid,$domain,$eventname,$timespec,$attr);
isnt($sched_id,undef,$description);
$num_tests++;
$num_events++;

$description = "Check that single event is saved to database";
$schedEv = Kynetx::Persistence::SchedEv::get_sched_ev($sched_id);
is($schedEv->{'once'},$timespec,$description);
$num_tests++;

$description = "Events with past schedule get now for next_schedule";
$timespec = $lessYear;
my $e_time = Kynetx::Predicates::Time::ISO8601($timespec)->epoch();
$sched_id = Kynetx::Persistence::SchedEv::single_event($user_ken,$rid,$domain,$eventname,$timespec,$attr);
$schedEv = Kynetx::Persistence::SchedEv::get_sched_ev($sched_id);
is($schedEv->{'next_schedule'} > $e_time,1,$description);
$num_tests++;
$num_events++;

my $sent_event_name = "slartibartfast";
$attr = {
  '_rids' => 'a144x157.prod',
  'ahash' => {
    'a' => 'apple',
    'b' => 'bushpig'
  }
};

$description = "Schedule for 5 hours in future";
$timespec = $plusFive;
$e_time = Kynetx::Predicates::Time::ISO8601($now)->epoch()  + 60*60*5;
$sched_id = Kynetx::Persistence::SchedEv::single_event($user_ken,$rid,$domain,$sent_event_name,$timespec,$attr);
$schedEv = Kynetx::Persistence::SchedEv::get_sched_ev($sched_id);
is($schedEv->{'next_schedule'} ,$e_time,$description);
$num_tests++;
$num_events++;

# save this SchedEv id for testing later
my $recurring_event = $sched_id;

$description = "A send event can be built from a schedEv";
$result = Kynetx::Modules::Event::send_scheduled_event($recurring_event);
is($result->code(),'200',$description);
$num_tests++;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
$year += 1900;
my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my $month = $abbr[$mon];

# Smoke test is not set up to install rulesets

#$description = "Event is timely";
#my $expected = qr/.+foo sits.+$mday $month $year $hour/;
#cmp_deeply($result->decoded_content(),re($expected),$description);
#$num_tests++;

$description = "A bad schedId blows up";
$result = Kynetx::Modules::Event::send_scheduled_event('_fake_');
is($result,undef,$description);
$num_tests++;

my $key = {
  "ken" => $user_ken,
  "source" => $rid
};
$description = "Look for scheduled events";
$result = Kynetx::Persistence::SchedEv::get_schedev_list($key);
cmp_deeply(scalar @{$result},$num_events,$description);
$num_tests++;
$logger->debug("SchedEvs: ", sub {Dumper($result)});

$description = "Delete scheduled events for an entity";
$result = Kynetx::Persistence::SchedEv::delete_entity_sched_ev($user_ken,$rid);
cmp_deeply($result,$num_events,$description);
$num_tests++;

$description = "No schedEv left";
$result = Kynetx::Persistence::SchedEv::get_schedev_list($key);
cmp_deeply(scalar @{$result},0,$description);
$num_tests++;

Kynetx::Test::flush_test_user($user_ken,$uname);

plan tests => $num_tests;
1;