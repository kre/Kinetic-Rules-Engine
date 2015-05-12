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
use Kynetx::Persistence::DevLog qw/:all/;


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
my $blank_env = Kynetx::Test::gen_rule_env();

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
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$rule_env,$session,[]);
isnt($result,0,$description);
$test_count++;

$description = "Check empty key";
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$blank_env,$session,[]);
is($result,0,$description);
$test_count++;

$description = "Check explicit key";
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$blank_env,$session,$keys);
is($result,1,$description);
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
	"email" => "flip\@flopper.com"
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


$description = "Check for username exists, explicit permissions 2nd";
$args = [$uname,$keys];
$result = Kynetx::Modules::PCI::check_username($my_req_info,$blank_env,$session,$rule_name,"foo",$args);
is($result,1,$description);
$test_count++;

$description = "Check for username exists, explicit permissions 1st";
$args = [$keys,$uname];
$result = Kynetx::Modules::PCI::check_username($my_req_info,$blank_env,$session,$rule_name,"foo",$args);
is($result,1,$description);
$test_count++;

Log::Log4perl->easy_init($INFO);

$description = "Check for username exists (false)";
my $new_uname = $uname . '-dep';
$args = $new_uname;
$result = Kynetx::Modules::PCI::check_username($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
is($result,0,$description);
$test_count++;

$description = "get profile";
$args = [$eci,$keys];
$result = Kynetx::Modules::PCI::get_account_profile($my_req_info,$blank_env,$session,$rule_name,"foo",$args);
#diag Dumper $result;
my $prfl = {"username" => $uname,
	    "email" => "flip\@flopper.com",
	    "firstname" => "Bill",
	    "lastname" => "Last",
	   };
is_deeply($result,$prfl,$description);
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


my $test_pci_auth_password = "foomanchoo";
$description = "Try to set password without credentials";
$expected = 0;
$result = Kynetx::Modules::PCI::set_account_password($my_req_info,$blank_env,$session,$rule_name,"foo",[$uname,$new_password,$test_pci_auth_password]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Password not set";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$new_password]);
is($result,1,$description);
$test_count++;

$description = "Try to set password with explicit credentials";
$expected = 1;
$result = Kynetx::Modules::PCI::set_account_password($my_req_info,$blank_env,$session,$rule_name,"foo",[$uname,$new_password,$test_pci_auth_password,$keys]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Password is set (with explicit credentials)";
$expected = { 'nid' => ignore() };
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$blank_env,$session,$rule_name,"foo",[$uname,$keys,$test_pci_auth_password]);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Set \$new_password with order sensitive parameters";
$expected = 1;
$result = Kynetx::Modules::PCI::set_account_password($my_req_info,$blank_env,$session,$rule_name,"foo",[$keys,$uname,$test_pci_auth_password,$new_password]);
is($result,1,$description);
$test_count++;

$description = "Fail the old password";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$test_pci_auth_password]);
is($result,0,$description);
$test_count++;

$description = "Pass the expected password";
$result = Kynetx::Modules::PCI::account_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[$uname,$new_password]);
is($result,1,$description);
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
diag "#### ECIs ####";

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

diag "xxxxx";

$description = "Add an ECI";
$expected = {
	'nid' => $uid,
	'name' => "Generic ECI channel",
	'cid' => re(qr/$uuid_re/)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$uid]);
cmp_deeply($result,$expected,$description);
$test_count++;

diag "yyyyy";

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
$result = Kynetx::Modules::PCI::get_eci_attributes($my_req_info,
						   $rule_env,
						   $session,
						   $rule_name,
						   "foo",
						   [$pre_result->{'cid'}]
						 );

#diag Dumper $result;

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


######################### Logging tests

my ($root_env,$username, $user_ken,$user_eci, $dev_ken,$dev_eci,$dev_env, $dev_secret);
my ($log_eci,$fqurl,$base_url,$ruleset,$opts,$mech,$eid,$dn,$platform);
$platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');

$root_env= Kynetx::Test::gen_root_env($my_req_info,$rule_env,$session);

$username = $DICTIONARY[rand(@DICTIONARY)];
chomp($username);

$user_ken = Kynetx::Test::gen_user($my_req_info,$root_env,$session,$username);
$user_eci = Kynetx::Persistence::KToken::get_oldest_token($user_ken);

$dev_ken = $session_ken;
$dev_eci = Kynetx::Persistence::KToken::create_token($dev_ken,"_null_","temp");
($dev_env,$dev_secret) = Kynetx::Test::gen_dev_env($my_req_info,$root_env,$session,$dev_eci);

$ruleset = "a144x132";
$eid = time;
$mech = Test::WWW::Mechanize->new(cookie_jar => undef);
$dn = "http://$platform/sky/event";
$base_url = "$dn/$user_eci/$eid";

########### Logging admin

$description = "Developer test environment created";
isnt($dev_env,undef,$description);
$test_count++;

$description = "Add permissions to view logs";
$keypath = ['ruleset','log'];
$result = Kynetx::Modules::PCI::set_permissions($my_req_info,$root_env,$session,$rule_name,"foo",[$dev_eci,$dev_secret,$keypath]);
is($result,1,$description);
$test_count++;

$description = "get a single permission";
$result = Kynetx::Modules::PCI::get_permissions($my_req_info,$root_env,$session,$rule_name,"foo",[$dev_eci,$dev_secret,$keypath]);
is($result,1,$description);
$test_count++;

############ Logging methods
$description = "Activate logging for test_user";
$args = [$user_eci];
$log_eci = Kynetx::Modules::PCI::logging_eci($my_req_info,$root_env,$session,$rule_name,'foo',$args);
isnt($log_eci,undef,$description);
$test_count++;

$description="Logging now set for test_user";
$result = Kynetx::Modules::PCI::get_logging($my_req_info,$root_env,$session,$rule_name,'foo',$args);
is($result,1,$description);
$test_count++;

$description = "de-activate logging for test_user";
$args = [$user_eci];
Kynetx::Modules::PCI::clear_logging($my_req_info,$root_env,$session,$rule_name,'foo',$args);
$result = Kynetx::Modules::PCI::get_logging($my_req_info,$root_env,$session,$rule_name,'foo',$args);
is($result,0,$description);
$test_count++;

$description = "Create a new, active logging eci";
$log_eci = Kynetx::Modules::PCI::logging_eci($my_req_info,$root_env,$session,$rule_name,'foo',$args);
isnt($log_eci,undef,$description);
$test_count++;

# It doesn't actually have to fire the rule
# An uninstalled ruleset generates debug of it's own
$description = "URL generates debug";
$fqurl = "$base_url/web/pageview";
$opts = {
  '_rids' => $ruleset,
  'caller' => "http://www.windley.com/first.html"  
};
$expected = re(qr/$ruleset/);
$result = $mech->get(Kynetx::Util::mk_url($fqurl,$opts));
cmp_deeply($result->code,200,$description);
$test_count++;

sleep 1;

# $description = "Log created for ruleset";
# $args = [$log_eci];
# $result = Kynetx::Modules::PCI::get_log_messages($my_req_info,$dev_env,$session,$rule_name,'foo',$args);
# my $id = (keys %{$result})[0];
# cmp_deeply($result->{$id}->{'log_text'},$expected,$description);
# $test_count++;


Log::Log4perl->easy_init($INFO);


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


