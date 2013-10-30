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
use Kynetx::Persistence::KPDS qw/:all/;


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

my $system_key = Kynetx::Modules::PCI::create_system_key();
$description = "Create and verify system key";
$result = Kynetx::Modules::PCI::check_system_key($system_key);
is($result,1,$description);
$test_count++;
my $keys = {'root' => $system_key};

my $count = 0;

# system authorized tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'system_credentials',
  $keys);

$description = "Check system key";
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[]);
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

Log::Log4perl->easy_init($DEBUG);

$keypath = ['ruleset','destroy'];
$description = "get a single permission";
$result = Kynetx::Modules::PCI::get_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$new_token,$dk2,$keypath]);
is($result,0,$description);
$test_count++;
Log::Log4perl->easy_init($INFO);
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

$logger->trace("Username: ", sub {Dumper($uname)});

$description = "Check for username exists";
$args = $uname;
$result = Kynetx::Modules::PCI::check_username($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
is($result,1,$description);
$test_count++;


$description = "Check for username exists (false)";
my $new_uname = $uname . '-dep';
$args = $new_uname;
$result = Kynetx::Modules::PCI::check_username($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
is($result,0,$description);
$test_count++;

$description = "Create a dependent account";
$args = {
	"username" => $new_uname,
	"firstname" => "",
	"lastname" => "",
	"password" => "",
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$args]);
isnt($result,undef,$description);
$test_count++;

my $eci2 = $result->{'cid'};
$logger->trace("Dep: ",sub {Dumper($eci2)});

$description = "Create another dependent account";
$args = {
	"username" => "$new_uname" . 2,
	"firstname" => "",
	"lastname" => "",
	"password" => "",
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$args]);
isnt($result,undef,$description);
$test_count++;
my $eci3 = $result->{'cid'};

$description = "Create a dependent account to a dependent account";
$args = {
	"username" => "$new_uname" . "dep",
	"firstname" => "",
	"lastname" => "",
	"password" => "",
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci2,$args]);
isnt($result,undef,$description);
$test_count++;


$description = "Check for username exists (true)";
$new_uname = $uname . '-dep';
$args = $new_uname;
$result = Kynetx::Modules::PCI::check_username($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
is($result,1,$description);
$test_count++;

$description = "Get child accounts";
$expected = [[ignore(),$new_uname,"_LOGIN"],[ignore(),$new_uname.2,"_LOGIN"]];
$args = {'username' => $uname};
$result = Kynetx::Modules::PCI::list_children($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Get child accounts of child";
$expected = [[ignore(),$new_uname."dep","_LOGIN"]];
$args = {'username' => $new_uname};
$result = Kynetx::Modules::PCI::list_children($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Get parent of top level account";
$args = $eci;
$result = Kynetx::Modules::PCI::list_parent($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
is($result,undef,$description);
$test_count++;

$description = "Get parent of dependent account";
$args = $eci2;
$result = Kynetx::Modules::PCI::list_parent($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
isnt($result,undef,$description);
$test_count++;

$description = "Get parent of dependent account";
$args = $eci3;
$result = Kynetx::Modules::PCI::list_parent($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
isnt($result,undef,$description);
$test_count++;


$description = "Change owner of account";
$args = [$eci3,$eci2];
$result = Kynetx::Modules::PCI::set_parent($my_req_info,$rule_env,$session,$rule_name,"foo",$args);
my $p_account = Kynetx::Modules::PCI::list_parent($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci3]);
$logger->trace("New parent: ",sub {Dumper($p_account)});

$description = "Is child added to $eci2";
$expected = bag([ignore(),$new_uname . 2,"_LOGIN"],
                [ignore(),$new_uname. "dep","_LOGIN"]);
$args = $eci2;
$result = Kynetx::Modules::PCI::list_children($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
cmp_deeply($result,$expected,$description);
$test_count++;
$logger->trace("Children of $eci2: ", sub {Dumper($result)});

$description = "Is child removed from $eci";
$expected = [[ignore(),$new_uname,"_LOGIN"]];
$args = $eci;
$result = Kynetx::Modules::PCI::list_children($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
cmp_deeply($result,$expected,$description);
$test_count++;
$logger->trace("Children of $eci: ", sub {Dumper($result)});  
  
  
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

$logger->trace("Account authorizations: ");


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

my $new_password = "babylon";
$expected = 1;
$description = "Change Password with username";
$result = Kynetx::Modules::PCI::set_account_password($my_req_info,$rule_envt,$session,$rule_name,"foo",[$uname,$password,$new_password]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Authorize KEN for new password";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$new_password]);
is($result,1,$description);
$test_count++;

$description = "Fail the old password";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$password]);
is($result,0,$description);
$test_count++;

$new_password = "ResetME";
$expected = 1;
$description = "Reset Password with username";
$result = Kynetx::Modules::PCI::reset_account_password($my_req_info,$rule_envt,$session,$rule_name,"foo",[$uname,$new_password]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Authorize KEN for reset password";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$new_password]);
is($result,1,$description);
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
	'cid' => re(qr/$uuid_re/)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci]);
cmp_deeply($result,$expected,$description);
$test_count++;
push(@new_eci, $result->{'cid'});

$description = "Add an ECI";
$expected = {
	'nid' => $uid,
	'name' => "Generic ECI channel",
	'cid' => re(qr/$uuid_re/)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;

push(@new_eci, $result->{'cid'});

$description = "Add a named ECI";
$expected = {
	'nid' => $uid,
	'name' => $uname,
	'cid' => re(qr/$uuid_re/)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname}]);
cmp_deeply($result,$expected,$description);
$test_count++;

push(@new_eci, $result->{'cid'});


$description = "Show eci for $uid";
$expected = {
	'nid' => $uid,
	'channels' => array_each({
		'name' => re(qr/\w+/),
		'cid' => re(qr/$uuid_re/)
	})
};
$result = Kynetx::Modules::PCI::list_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "delete eci for $uid";
my $eciD = $new_eci[0];
$result = Kynetx::Modules::PCI::destroy_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$eciD]);
my $string = Kynetx::Json::astToJson($result);
isnt($result,re(qr/$eci/),$description);
$test_count++;

$description = "Show eci for $uid";
$expected = {
	'nid' => $uid,
	'channels' => array_each({
		'name' => re(qr/\w+/),
		'cid' => re(qr/$uuid_re/)
	})
};
$result = Kynetx::Modules::PCI::list_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;


####### Predicates (after ECIs have been created)
# check that predicates at least run without error
Log::Log4perl->easy_init($DEBUG);


my $temp_ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($uid);
my @token_list = map {$_->{'cid'}} @{Kynetx::Persistence::KToken::list_tokens($temp_ken)};

$description = "Check is_related (match)";
@dummy_arg = ($eci,\@token_list);
$expected = 1;
$result = &{$preds->{'is_related'}}($my_req_info, $rule_env,\@dummy_arg);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Check is_related (no match)";
@dummy_arg = ($eci2,\@token_list);
$expected = 0;
$result = &{$preds->{'is_related'}}($my_req_info, $rule_env,\@dummy_arg);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Jessie test";
my $static_eci = "D808DAC2-84E6-11E2-B4CC-22BD87B7806A";
my @t_list = ("D808DAC2-84E6-11E2-B4CC-22BD87B7806A");
@dummy_arg = ($static_eci,\@t_list);
$expected = 1;
$result = &{$preds->{'is_related'}}($my_req_info, $rule_env,\@dummy_arg);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Jessie test2";
$static_eci = "D808DAC2-84E6-11E2-B4CC-22BD87B7806A";
@t_list = ("D808DAC2-84E6-11E2-B4CC-22BD87B7806B");
@dummy_arg = ($static_eci,\@t_list);
$expected = 0;
$result = &{$preds->{'is_related'}}($my_req_info, $rule_env,\@dummy_arg);
cmp_deeply($result,$expected,$description);
$test_count++;

####### ECI Attributes and Policy

my ($pre_result, $first);

$description = "Add an ECI with attributes";
$expected = ['hello', 'goodbye'];
$pre_result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname, 'attributes' => $expected}]);
#diag Dumper $result;
$result = Kynetx::Modules::PCI::get_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'}]
						 );
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Add ECI attributes";
$expected = ['hello', 'goodbye'];
$pre_result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname}]);
#diag "Pre: ", Dumper $pre_result;
$result = Kynetx::Modules::PCI::set_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'},
						    $expected
						   ]
						 );
#diag "Set: ", Dumper $result;
$result = Kynetx::Modules::PCI::get_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'}]
						 );
#diag "Get: ", Dumper $result;
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Change ECI attributes";
$first =  ['foo', 'bar'];
$expected = ['hello', 'goodbye'];
$pre_result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname, 'attributes' => $first}]);
#diag "Pre: ", Dumper $pre_result;

# make sure they stuck
$result = Kynetx::Modules::PCI::get_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'}]
						 );
#diag "Get: ", Dumper $result;
cmp_deeply($result,$first,$description);
$test_count++;

# now change them
$result = Kynetx::Modules::PCI::set_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'},
						    $expected
						   ]
						 );
#diag "Set: ", Dumper $result;
$result = Kynetx::Modules::PCI::get_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'}]
						 );
#diag "Get: ", Dumper $result;
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Add an ECI with policy";
$expected = {'add_ok' => 1, 'places' => [1,2,3,4]};
$pre_result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname, 'policy' => $expected}]);
#diag "ECI Creation: ", Dumper $pre_result;
$result = Kynetx::Modules::PCI::get_eci_policy($my_req_info,
					       $rule_env,
					       $session,
					       $rule_name,
					       "foo",
					       [$pre_result->{'cid'}]
					      );
#diag "Result: ", Dumper $result;
cmp_deeply($result,$expected,$description);
$test_count++;


$description = "Add ECI policy";
$expected = {'add_ok' => 1, 'places' => [1,2,3,4]};
$pre_result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname}]);
#diag "Pre: ", Dumper $pre_result;
$result = Kynetx::Modules::PCI::set_eci_policy($my_req_info,
					       $rule_env,
					       $session,
					       $rule_name,
					       "foo",
					       [$pre_result->{'cid'},
						$expected
					       ]
					      );
#diag "Set: ", Dumper $result;
$result = Kynetx::Modules::PCI::get_eci_policy($my_req_info,
					       $rule_env,
					       $session,
					       $rule_name,
					       "foo",
					       [$pre_result->{'cid'}]
					      );
#diag "Get: ", Dumper $result;
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Change ECI policy";
$expected = {'add_ok' => 1, 'places' => [1,2,3,4]};
$first = {'foo' => [1,2,3], 'bar' => {'hello' => 'world'}};
$pre_result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid,{'name' => $uname, 'policy' => $first}]);
#diag "Pre: ", Dumper $pre_result;

# make sure it stuck
$result = Kynetx::Modules::PCI::get_eci_policy($my_req_info,
					       $rule_env,
					       $session,
					       $rule_name,
					       "foo",
					       [$pre_result->{'cid'}]
					      );
#diag "Get: ", Dumper $result;
cmp_deeply($result,$first,$description);
$test_count++;

# now make sure we can change it
$result = Kynetx::Modules::PCI::set_eci_policy($my_req_info,
					       $rule_env,
					       $session,
					       $rule_name,
					       "foo",
					       [$pre_result->{'cid'},
						$expected
					       ]
					      );
#diag "Set: ", Dumper $result;
$result = Kynetx::Modules::PCI::get_eci_policy($my_req_info,
					       $rule_env,
					       $session,
					       $rule_name,
					       "foo",
					       [$pre_result->{'cid'}]
					      );
#diag "Get: ", Dumper $result;
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


