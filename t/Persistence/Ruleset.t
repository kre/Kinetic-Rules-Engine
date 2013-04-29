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
use utf8;

use Test::More;
use Test::Deep;
use Data::Dumper;
use MongoDB;
use Apache::Session::Memcached;
use APR::Pool ();

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
use Kynetx::Repository qw/:all/;
use Kynetx::Persistence::KEN qw/:all/;
use Kynetx::Modules::PCI;
use Kynetx::Keys;
use Kynetx::Persistence::Ruleset qw(:all);
use Kynetx::Persistence::KPDS qw(:all);
use Kynetx::Persistence::KToken qw(:all);
use Kynetx::Parser qw/:all/;
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
my $ken;
my $description;
my $test_count = 0;
my($config, $mods, $args, $krl, $krl_src, $js, $expected);

my $rid = "cs_test";
my $tsession;


my $r = new Kynetx::FakeReq();
$r->_delete_session();
$logger->debug("r: ", sub {Dumper($r)});


# Set the session, find a KEN
$r = new Kynetx::FakeReq();
$r->_set_session($tsession);
my $rule_env = Kynetx::Test::gen_rule_env();
my $my_req_info = Kynetx::Test::gen_req_info($rid);
my $session = process_session($r);
my $session_ken = Kynetx::Persistence::KEN::get_ken($session);
$logger->debug("Session Ken: ", $session_ken);

# get a random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $prefix = $DICTIONARY[rand(@DICTIONARY)];
chop $prefix;
my $uname = $DICTIONARY[rand(@DICTIONARY)];
chomp($uname);
my $rule_name = $DICTIONARY[rand(@DICTIONARY)];
chomp($rule_name);

# Create a fake Developer
my $system_key = Kynetx::Modules::PCI::create_system_key($result);
$logger->debug("Key: $system_key");
$description = "Create and verify system key";
$result = Kynetx::Modules::PCI::check_system_key($system_key);
is($result,1,$description);
$test_count++;
$logger->debug("match: $result");
my $keys = {'root' => $system_key};

# system authorized tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'system_credentials',
  $keys);
  
$description = "Create a new account";
my $password = "Flooply";
$args = {
	"username" => $uname,
	"firstname" => "Bill",
	"lastname" => "Last",
	"password" => $password,
};

$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
isnt($result,undef,$description);
my $eci = $result->{'cid'};

$test_count++;
$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');

$logger->debug("Developer ken: $ken User: $userid");
$description = "First generic rid";
$expected = 'b' . $userid .'x0.prod';
$rid = Kynetx::Persistence::Ruleset::create_rid($ken);
is($rid,$expected,$description);
$test_count++;


$logger->debug("Rid: $rid");

$description = "Second generic rid";
$expected = 'b' . $userid .'x1.prod';
$rid = Kynetx::Persistence::Ruleset::create_rid($ken);
is($rid,$expected,$description);
$test_count++;

$logger->debug("Rid: $rid");
$description = "First prefix rid ($prefix)";
$expected = $prefix . $userid .'x0.prod';
$rid = Kynetx::Persistence::Ruleset::create_rid($ken,$prefix);
is($rid,$expected,$description);
$test_count++;

$logger->debug("Rid: $rid");

$description = "Second prefix rid ($prefix)";
$expected = $prefix . $userid .'x1.prod';
$rid = Kynetx::Persistence::Ruleset::create_rid($ken,$prefix);
is($rid,$expected,$description);
$test_count++;
$logger->debug("Rid: $rid");

$description = "Pull proto registry entry";
$expected = {
  'created' => ignore(),
  'value' => {
    'owner' => $ken,
    'rid_index' => re(qr/\d+/),
    'prefix' => re(qr/$prefix/)
  },
  'rid' => $rid
};
$result = Kynetx::Persistence::Ruleset::get_registry($rid);
cmp_deeply($result,$expected,$description);
$test_count++;
$logger->debug("Registry: ", sub {Dumper($result)});

my $local_file = 'data/action5.krl';
my $uri = "https://raw.github.com/kre/Kinetic-Rules-Engine/master/t/" . $local_file;
$expected->{'value'}->{'uri'} = $uri;
Kynetx::Persistence::Ruleset::put_registry_element($rid,['uri'],$uri);
$result = Kynetx::Persistence::Ruleset::get_registry($rid);
cmp_deeply($result,$expected,$description);
$test_count++;
$logger->debug("Registry: ", sub {Dumper($result)});

$description = "Based on rid_info, get the ast";
my $rid_info = Kynetx::Persistence::Ruleset::get_ruleset_info($rid);
my ($fl,$krl_text) = getkrl($local_file);
my $ast = Kynetx::Rules::optimize_ruleset(parse_ruleset($krl_text));
# Optimization creates a state machine with different values
$ast->{'rules'}->[0]->{'event_sm'} = ignore();
$my_req_info = Kynetx::Test::gen_req_info($rid);
my $rules = Kynetx::Repository::get_rules_from_repository($rid_info, $my_req_info);
cmp_deeply($rules,$ast,$description);
$test_count++;




# Clean up anonymous KENS
my $ken_struct = {
	"_id" => MongoDB::OID->new('value' => "$session_ken")
};
$result = Kynetx::MongoDB::get_value('kens',$ken_struct);

if (defined $result && ref $result eq "HASH") {
	my $username = $result->{'username'};
	if ($username =~ m/^_/) {
		$logger->debug("Ken is anonymous");
		Kynetx::Persistence::KPDS::delete_cloud($session_ken);
	}
	Kynetx::Persistence::KPDS::delete_cloud($ken);
}

sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    cmp_deeply($got,$expected,$description);
}
ENDY:
session_cleanup($session);

plan tests => $test_count;
1;
