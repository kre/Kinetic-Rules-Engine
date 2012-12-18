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

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use Storable 'dclone';

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Modules::PCI qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Response qw/:all/;


use Kynetx::FakeReq qw/:all/;
use Kynetx::Util qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();


my $preds = Kynetx::Modules::PCI::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';


# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $session_ken = Kynetx::Persistence::KEN::get_ken($session,"null");

my $test_count = 0;


my($config, $mods, $args, $krl, $krl_src, $js, $result, $v,$description,$dev_key,$eci,$uid,$expected);
my $uuid_re = "^[A-F|0-9]{8}\-[A-F|0-9]{4}\-[A-F|0-9]{4}\-[A-F|0-9]{4}\-[A-F|0-9]{12}\$";

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
]);


# get a random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $frid = $DICTIONARY[rand(@DICTIONARY)];
chomp($frid);

my $uname = $DICTIONARY[rand(@DICTIONARY)];
chomp($uname);

my $rrid1 = $DICTIONARY[rand(@DICTIONARY)];
chomp($rrid1);

my $rrid2 = $DICTIONARY[rand(@DICTIONARY)];
chomp($rrid2);

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

$description = "Check system key";
$result = Kynetx::Modules::PCI::system_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[]);
isnt($result,undef,$description);
$test_count++;

# System level operations

$description = "Create a developer key";
$result = Kynetx::Modules::PCI::developer_key($my_req_info,$rule_env,$session,$rule_name,"foo",[]);
isnt($result,undef,$description);
$test_count++;
$dev_key = $result;

my $new_token = Kynetx::Persistence::KToken::create_token($session_ken,"_null_","temp");

$description = "Create a developer key from a token";
$result = Kynetx::Modules::PCI::developer_key($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token]);
isnt($result,undef,$description);
$test_count++;
my $dev_creds = {
	'developer_eci' => $new_token,
	'developer_secret' => $result
};


$description = "Multiple dev keys";
isnt($result,$dev_key,$description);
$test_count++;

my $dk2 = $result;


$description = "Check default test permission";
$result = Kynetx::Modules::PCI::get_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,['cloud','auth']]);
#$session_ken,$dev_key);
is($result,1,$description);
$test_count++;

my $keypath = ['ruleset','destroy'];
$description = "Set a single permission";
$result = Kynetx::Modules::PCI::set_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,1,$description);
$test_count++;


$keypath = ['ruleset','destroy'];
$description = "get a single permission";
$result = Kynetx::Modules::PCI::get_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,1,$description);
$test_count++;

$description = "Check default test no permission";
$result = Kynetx::Modules::PCI::get_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",['ruleset','destroy']);
is($result,0,$description);
$test_count++;

$keypath = ['ruleset','create'];
$description = "Set a permission for ruleset create";
$result = Kynetx::Modules::PCI::set_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,1,$description);
$test_count++;

$keypath = ['ruleset','destroy'];
$description = "Set a single permission";
$result = Kynetx::Modules::PCI::clear_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,0,$description);
$test_count++;


$keypath = ['ruleset','destroy'];
$description = "get a single permission";
$result = Kynetx::Modules::PCI::get_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,0,$description);
$test_count++;

$keypath = ['ruleset','destroy'];
$description = "Set a single permission";
$result = Kynetx::Modules::PCI::set_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,1,$description);
$test_count++;

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
$test_count++;
$eci = $result->{'cid'};
$uid = $result->{'nid'};


$description = "Create a dependent account";
$args = {
	"username" => $uname . '-dep',
	"firstname" => "",
	"lastname" => "",
	"password" => "",
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$args]);
isnt($result,undef,$description);
$test_count++;

($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'system_credentials',
  $dev_creds);
  
  
  
$description = "Use embedded keys to identify developer and permissions";
$result = Kynetx::Modules::PCI::developer_authorized($my_req_info,$rule_env,$session,['cloud', 'auth']);
is($result,1,$description);
$test_count++;

$description = "Use embedded keys to identify developer and lack of permissions";
$result = Kynetx::Modules::PCI::developer_authorized($my_req_info,$rule_env,$session,['cloud', 'create']);
is($result,0,$description);
$test_count++;

#$logger->debug("Account authorizations: ");


$description = "Authorize KEN for username $uname";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$password]);
is($result,1,$description);
$test_count++;

$description = "Authorize KEN for dependent account";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",["$uname-dep",$password]);
is($result,1,$description);
$test_count++;

$description = "Authorize KEN with hash username";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[{'username' => $uname},$password]);
is($result,1,$description);
$test_count++;

my ($jst, $rule_envt) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'system_credentials',
  $keys);

$expected = {
  'nid' => $uid
};
$description = "Authorize KEN with hash userid";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_envt,$session,$rule_name,"foo",[{'user_id' => $uid},$password]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Throw in a fail for fun";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[{'user_id' => $uid},$password . "B"]);
is($result,0,$description);
$test_count++;

####### RULESETS
$description = "Add ruleset to userid";
$expected = {
	'nid' => $uid,
	'rids' => [$rrid1]
};
$result = Kynetx::Modules::PCI::add_ruleset_to_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,$rrid1]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Add ruleset to userid";
$expected = {
	'nid' => $uid,
	'rids' => [$rrid1,$rrid2]
};
$result = Kynetx::Modules::PCI::add_ruleset_to_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,$rrid2]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "List rulesets";
$expected = {
	'nid' => $uid,
	'rids' => bag($rrid1,$rrid2)
};
$result = Kynetx::Modules::PCI::installed_rulesets($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci]);
cmp_deeply($result,$expected,$description);
$test_count++;


$description = "Remove a ruleset";
$expected = {
	'nid' => $uid,
	'rids' => [$rrid2]
};
$result = Kynetx::Modules::PCI::remove_ruleset_from_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$rrid1]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "List rulesets";
$expected = {
	'nid' => $uid,
	'rids' => [$rrid2]
};
$result = Kynetx::Modules::PCI::installed_rulesets($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Add ruleset to eci";
$expected = {
	'nid' => $uid,
	'rids' => bag($rrid1,$rrid2)
};
$result = Kynetx::Modules::PCI::add_ruleset_to_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$rrid1]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Remove two rulesets";
$expected = {
	'nid' => $uid,
	'rids' => []
};
$result = Kynetx::Modules::PCI::remove_ruleset_from_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,[$rrid1,$rrid2]]);
cmp_deeply($result,$expected,$description);
$test_count++;

####### ECI
my @new_eci = ();
$description = "Add an ECI";
$expected = {
	'nid' => $uid,
	'name' => "Generic ECI channel",
	'cid' => re($uuid_re)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci]);
cmp_deeply($result,$expected,$description);
$test_count++;
push(@new_eci, $result->{'cid'});

$description = "Add an ECI";
$expected = {
	'nid' => $uid,
	'name' => "Generic ECI channel",
	'cid' => re($uuid_re)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;

push(@new_eci, $result->{'cid'});

$description = "Show eci for $uid";
$expected = {
	'nid' => $uid,
	'channels' => array_each({
		'name' => re(/\w+/),
		'cid' => re($uuid_re)
	})
};
$result = Kynetx::Modules::PCI::list_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "delete eci for $uid";
my $eciD = $new_eci[0];
$result = Kynetx::Modules::PCI::destroy_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$eciD]);
my $string = Kynetx::Json::astToJson($result);
isnt($result,re(/$eci/),$description);
$test_count++;

$description = "Show eci for $uid";
$expected = {
	'nid' => $uid,
	'channels' => array_each({
		'name' => re(/\w+/),
		'cid' => re($uuid_re)
	})
};
$result = Kynetx::Modules::PCI::list_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;

####### CLEANUP

Kynetx::Persistence::KPDS::revoke_developer_key($session_ken,$dk2);
$description = "Revoke a developer key";
$result = Kynetx::Persistence::KPDS::get_developer_permissions($session_ken,$dk2,['cloud','auth']);
is($result,0,$description);
$test_count++;


($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'system_credentials',
  $keys);
$logger->debug("Delete: $eci");
$description = "Delete account and dependents";
$args = {
	"cascade" => 1
};
$result = Kynetx::Modules::PCI::delete_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$args]);
isnt($result,undef,$description);
$test_count++;


ENDY:

done_testing($test_count);



1;


