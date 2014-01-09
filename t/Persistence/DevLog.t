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
use Test::WWW::Mechanize;
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
use Kynetx::Persistence::DevLog qw/:all/;
use Kynetx::Persistence::KPDS qw/:all/;
use Kynetx::Predicates::Time qw/:all/;
use Kynetx::Modules::Event;

my $logger = get_logger();
my $num_tests = 0;

# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my ($result,@results,$description,$expected,$args,@expected);

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;



##############################################################
#
# Create the request environment
#
##############################################################

my ($my_req_info,$r,$rule_env,$rid,$rule_name,$js,$session,$username);
my ($password,$anon,$platform,$mech,$dn,$base_url,$ruleset,$eid);
$rid = "initial_setup";
$rule_name = "foo";
$ruleset = "a144x132";
$eid = time;
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();
$r = Kynetx::Test::configure();
$session = Kynetx::Test::gen_session($r,$rid);
$anon = Kynetx::Persistence::KEN::get_ken($session,$rid);

$platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');

$mech = Test::WWW::Mechanize->new(cookie_jar => undef);
$dn = "http://$platform/sky/event";


$username =  $DICTIONARY[rand(@DICTIONARY)];
chomp($username);

$password =  $DICTIONARY[rand(@DICTIONARY)];
chomp($password);

my $root_env = Kynetx::Test::gen_root_env($my_req_info,$rule_env,$session);

$description = "Is root env";
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$root_env,$session,$rule_name,"foo",[]);
is($result,1,$description);
$num_tests++;

my $test_user = Kynetx::Test::gen_user($my_req_info,$root_env,$session,$username);
$description = "Create test user";
isnt($test_user,undef,$description);
$num_tests++;

my $test_eci = Kynetx::Persistence::KToken::get_oldest_token($test_user);
$description = "Get test user ECI";
isnt($test_eci,undef,$description);
$num_tests++;

$description = "Add a ruleset to the test user";
$args = [$test_eci,[$ruleset]];
$expected = {
  'nid' => ignore(),
  'rids' => [$ruleset]
};
$result = Kynetx::Modules::PCI::add_ruleset_to_account($my_req_info,$root_env,$session,$rule_name,"foo",$args);
cmp_deeply($result,$expected,$description);
$num_tests++;
$base_url = "$dn/$test_eci/$eid";




##############################################################
#
# DevLog
#
##############################################################
my ($domain,$eventname,$fqurl,$resp,$opts,$log_id);
my $max_array = 15;
my @msgs = ();
my $index = 0;

my $maxlog = Kynetx::Configure::get_config('MONGO_LOG_SIZE');



for (my $i=0; $i<$max_array; $i++) {
  my $word = $DICTIONARY[rand(@DICTIONARY)];
  chomp $word;
  push @msgs, $word;
}

$description="Logging not set for test_user";
$result = Kynetx::Persistence::DevLog::has_logging($test_user);
is($result,0,$description);
$num_tests++;

$description = "Activate logging for test_user";
$args = [$test_eci];
my $logging_eci = Kynetx::Modules::PCI::logging_eci($my_req_info,$root_env,$session,$rule_name,'foo',$args);
isnt($logging_eci,undef,$description);
$num_tests++;

$description="Logging now set for test_user";
$result = Kynetx::Persistence::DevLog::has_logging($test_user);
is($result,1,$description);
$num_tests++;

$description = "rule fires";
$fqurl = "$base_url/web/pageview";
$opts = {
  '_rids' => $ruleset,
  'caller' => "http://www.windley.com/first.html"  
};
$expected = re(qr/test_rule_first/);
my $turl = Kynetx::Util::mk_url($fqurl,$opts);
$resp = $mech->get_ok($turl,$opts,$description);
#cmp_deeply($resp->content,$expected,$description);
$num_tests++;

# Logging is not "safe", give mongo a second to catch up
# or for asynch call to complete
sleep 1;

$description = "Request is logged";
$result = Kynetx::Persistence::DevLog::get_all_msg($logging_eci);
cmp_deeply(scalar keys %{$result},1,$description);
$num_tests++;

#goto ENDY;

foreach my $var (@msgs) {
  $eventname = $var;
  $fqurl = "$base_url/web/$eventname";
  $opts = {
    '_rids' => $ruleset,
    'caller' => "http://www.windley.com/first.html"
  };
  $resp = $mech->get(Kynetx::Util::mk_url($fqurl,$opts));
}

sleep 1;

$description = "All requests logged";
$result = Kynetx::Persistence::DevLog::get_all_msg($logging_eci);
cmp_deeply(scalar keys %{$result},$max_array + 1,$description);
$num_tests++;

$description = "$maxlog requests active";
$result = Kynetx::Persistence::DevLog::get_active($logging_eci);
cmp_deeply(scalar keys %{$result},$maxlog,$description);
$num_tests++;

$description = "Get a single log entry";
$index = int rand(scalar keys %{$result});
$log_id = (keys %{$result})[$index];
$expected = $result->{$log_id};
$result = Kynetx::Persistence::DevLog::get_log($logging_eci,$log_id);
cmp_deeply($result,$expected,$description);
$num_tests++;

$description = "Delete a log entry";
Kynetx::Persistence::DevLog::delete_log($logging_eci,$log_id);
$result = Kynetx::Persistence::DevLog::get_active($logging_eci);
cmp_deeply(scalar keys %{$result},$maxlog-1,$description);
$num_tests++;

ENDY:

plan tests => $num_tests;

##############################################################
#
# CLEANUP
#
##############################################################
if ($test_user) {
  Kynetx::Test::flush_test_user($test_user,$username);
}

1;