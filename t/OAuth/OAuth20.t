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
use Apache2::Const qw(:common :http M_GET M_POST);
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use Storable 'dclone';
use URI::Escape qw(
  uri_unescape
  uri_escape_utf8
);

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

my $dname = $DICTIONARY[rand(@DICTIONARY)];
chomp($dname);

my $rrid1 = $DICTIONARY[rand(@DICTIONARY)];
chomp($rrid1);

my $rrid2 = $DICTIONARY[rand(@DICTIONARY)];
chomp($rrid2);

my $system_key = Kynetx::Modules::PCI::create_system_key($result);
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

my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');

#goto ENDY;

$description = "Check system key";
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$rule_env,$session,$rule_name,"foo",[]);
isnt($result,undef,$description);
$test_count++;

BAIL_OUT("System key failure") unless $result;
# User account
$description = "Create a user account";
my $password = "Flooply-u";
$args = {
	"username" => $uname,
	"firstname" => "Test",
	"lastname" => "OAuth User",
	"password" => $password,
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
isnt($result,undef,$description);
$test_count++;
my $u_eci = $result->{'cid'};

# Developer account information
my $d_eci;
my $d_uid;

$description = "Create a new developer account";
$password = "Flooply-d";
$args = {
	"username" => $dname,
	"firstname" => "Test",
	"lastname" => "Developer",
	"password" => $password,
};
$result = Kynetx::Modules::PCI::new_account($my_req_info,$rule_env,$session,$rule_name,"foo",[$args]);
isnt($result,undef,$description);
$test_count++;
$eci = $result->{'cid'};
$d_uid = $result->{'nid'};

# Developer ken
my $dken = Kynetx::Persistence::KEN::ken_lookup_by_userid($d_uid);

diag $dken;

####### ECI
my @new_eci = ();
$description = "Add an ECI";
my $e_name = "OAuth Developer ECI";
my $e_type = "OAUTH";
my $eci_params = {
  'name' => $e_name,
  'eci_type' => $e_type
};

$expected = {
	'nid' => $d_uid,
	'name' => "OAuth Developer ECI",
	'cid' => re(qr/$uuid_re/)
};
$result = Kynetx::Modules::PCI::new_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$eci,$eci_params]);
cmp_deeply($result,$expected,$description);
$test_count++;

$d_eci = $result->{'cid'};

# Create a developer secret
$description = "Create a developer key";
$result = Kynetx::Modules::PCI::developer_key($my_req_info,$rule_env,$session,$rule_name,"foo",[]);
isnt($result,undef,$description);
$test_count++;
$dev_key = $result;


# Give developer permission to request access tokens
my $keypath = ['oauth','access_token'];
$description = "Set an oauth access_token permission";
$result = Kynetx::Modules::PCI::set_permissions($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$dev_key,$keypath]);
is($result,1,$description);
$test_count++;

# Add a callback to the developer oauth configuration
my $callback = Kynetx::Configure::get_config("oauth_server")->{"auth_ruleset"};
$callback =~ s/oauth_authorize/pageview/;
$description = "Add a callback url to developer eci";
$expected = [$callback];
$result = Kynetx::Modules::PCI::add_oauth_callback($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$callback]);
cmp_deeply($result,$expected,$description);
$test_count++;
my @cb = @{$result};


$callback = "http://www.bar.com/foo";
$description = "Add another callback url to developer eci";
push(@cb,$callback);
$expected = \@cb;
$result = Kynetx::Modules::PCI::add_oauth_callback($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$callback]);
ll(Dumper $result);
cmp_deeply($result,$expected,$description);
$test_count++;

$callback = pop(@cb);
$description = "Remove a callback";
$expected = \@cb;
$result = Kynetx::Modules::PCI::remove_callback($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$callback]);
ll(Dumper $result);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "List remaining callbacks";
$expected = \@cb;
$result = Kynetx::Modules::PCI::list_callback($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci]);
$logger->info("Callbacks: ",sub {Dumper($result)});
cmp_deeply($result,$expected,$description);
$test_count++;

###################### Add App info
$description = "Add OAuth application info";
my $app_info = {
  'icon' => 'https://squaretag.com/assets/img/st_logo_white_trans.png',
  'name' => "Burt's Magic Fingers",
  'description' => "Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me.",
  'info_page' => 'http://www.exampley.com'
};
$result = Kynetx::Modules::PCI::add_oauth_app_info($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$app_info]);
cmp_deeply($result,scalar keys %{$app_info},$description);
$test_count++;

$description = "Get OAuth application info";
$result = Kynetx::Modules::PCI::get_oauth_app_info($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci]);
cmp_deeply($result,$app_info,$description);
$test_count++;

$description = "Store OAuth secret";
$result = Kynetx::Modules::PCI::add_oauth_secret($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$dev_key]);
cmp_deeply($result,1,$description);
$test_count++;

$description = "Get OAuth secret";
$result = Kynetx::Persistence::KPDS::get_developer_secret($dken,$d_eci);
cmp_deeply($result,$dev_key,$description);
$test_count++;

$description = "Make authorization request uri: check client_id";
$expected = re(qr/client_id=$d_eci/);
$result = Kynetx::Modules::PCI::make_request_uri($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$cb[0]]);
ll(Dumper $result);
cmp_deeply($result,$expected,$description);
$test_count++;

$logger->info("client_id=$d_eci");

$description = "Make authorization request uri: check response_type";
$expected = re(qr/response_type=code/);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Make authorization request uri: check redirect";
my $encoded_uri = uri_escape_utf8($cb[0]);
$expected = re(qr/redirect_uri=$encoded_uri/);
cmp_deeply($result,$expected,$description);
$test_count++;

# Test the oauth authorize link
require LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->max_redirect(1);
my $oauth_request_uri = $result;
my $state;
my $bad_oauth_request;
if ($oauth_request_uri =~ m/state=([0-9|a-z|A-Z|_]+)/) {
  $state = $1;
}

#  building the request uri from scratch;
my $client_id = $d_eci;
my $response_type = 'code';
my $redirect = $cb[0];

$description = "POST not allowed";
$bad_oauth_request = test_request_url();
$expected = Apache2::Const::HTTP_METHOD_NOT_ALLOWED;
$result = $ua->post($bad_oauth_request);
cmp_deeply($result->code(),$expected,$description);
$test_count++;

$description = "Bad ECI";
$bad_oauth_request = test_request_url('foo',$response_type,$state,$redirect);
$expected = Apache2::Const::FORBIDDEN;
$result = $ua->get($bad_oauth_request);
cmp_deeply($result->code(),$expected,$description);
$test_count++;

$description = "Bad redirect URI";
$bad_oauth_request = test_request_url($client_id,$response_type,$state,"http://www.foo.com/");
$expected = Apache2::Const::HTTP_BAD_REQUEST;
$result = $ua->get($bad_oauth_request);
cmp_deeply($result->code(),$expected,$description);
$test_count++;

$ua->max_redirect(0);
$description = "Bad response request";
$bad_oauth_request = test_request_url($client_id,'request',$state,$redirect);
$expected = Apache2::Const::HTTP_MOVED_TEMPORARILY;
$result = $ua->get($bad_oauth_request);
cmp_deeply($result->code(),$expected,$description);
$test_count++;

$description = "Redirected location uses redirect url for error response";
$expected = re(qr/^$redirect.+error=unsupported_response_type/);
cmp_deeply(uri_unescape($result->header('Location')),$expected,$description);
$test_count++;

$description = "Check the redirect constructed by PCI";
$expected = Apache2::Const::HTTP_MOVED_TEMPORARILY;
$result = $ua->get($oauth_request_uri);
cmp_deeply($result->code(),$expected,$description);
$test_count++;



# test the Access Token
my $access_token_code = Kynetx::Modules::PCI::oauth_authorization_code($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci,$u_eci,$dev_key]);
my $base = Kynetx::Configure::get_config('oauth_server')->{'access'} || "oauth_not_configured";
ll($access_token_code);
ll($base);

$result = $ua->post($base,[
  'grant_type' => 'authorization_code',
  'code' => $access_token_code,
  'redirect_uri' => $cb[0],
  'client_id' => $d_eci
]);
$logger->debug("Return: ",$result->decoded_content());

$description = "Check to see that OAuth eci maps to access_token and ken";
my $json = Kynetx::Json::decode_json($result->content());
my $otoken = $json->{'access_token'};
my $oeci = Kynetx::Modules::PCI::get_oauth_token_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$otoken]);
$expected = Kynetx::Persistence::KEN::ken_lookup_by_token($u_eci);
$result = Kynetx::Persistence::KEN::ken_lookup_by_token($oeci);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Return the USER OAuth ECI";
my $user_OECI = $json->{'OAUTH_ECI'};
cmp_deeply($user_OECI,$oeci,$description);
$test_count++;

$description = "Look up OAuth ECIs by developer eci";
$expected = [$oeci];
$result = Kynetx::Modules::PCI::get_developer_oauth_eci($my_req_info,$rule_env,$session,$rule_name,"foo",[$d_eci]);
cmp_deeply($result,$expected,$description);
$test_count++;

BAIL_OUT("OAuth Token Fail") unless $otoken;

# Now with the OAuth token make a protected request

# GET
my $function = "get_setting_all";
my $ruleset = "pds";
my $params = ["_eci=$u_eci" ];
my $protected_url = "http://$platform/oauth/cloud/$ruleset/$function?".
		   join("&", @{$params});

push(@{$params},"access_token=$otoken");		   
my $query_url = "http://$platform/oauth/cloud/$ruleset/$function?".
		   join("&", @{$params});
		   
my $netloc = $platform . ":80";
my $realm = 'Kynetx';

$description = "Pass token in the query";
$result = $ua->get($query_url);
cmp_deeply($result->is_success(),1,$description);
$test_count++;

$params = ["_eci=$u_eci",'access_token=CaptainCrunch'];
$query_url = "http://$platform/oauth/cloud/$ruleset/$function?".
		   join("&", @{$params});
$description = "Pass a bad token in the query";
$result = $ua->get($query_url);
cmp_deeply($result->is_success(),'',$description);
$test_count++;

# POST
$params = {
  "_eci"=> $u_eci,
  'access_token' => $otoken
};

$description = "send a POST request";
$result = $ua->post("http://$platform/oauth/cloud/$ruleset/$function", $params);
cmp_deeply($result->is_success(),1,$description);
$test_count++;

$params->{'access_token'} = 'CountChockula';
$description = "send a bad POST request";
$result = $ua->post("http://$platform/oauth/cloud/$ruleset/$function", $params);
cmp_deeply($result->is_success(),'',$description);
$test_count++;

# Check header for tokens
$ua->default_header('Authorization' => "Bearer $otoken");

$description = "Make a PRR with valid token";
$result = $ua->get($protected_url);
cmp_deeply($result->is_success(),1,$description);
$test_count++;

$description = "Make a PRR with an invalid token in header";
$ua->default_header('Authorization' => "Bearer flooply");
$result = $ua->get($protected_url);
cmp_deeply($result->code(),401,$description);
$test_count++;


ENDY:

##############################################################
#
# Create the request environment
#
##############################################################

my ($anon,$mech,$dn,$base_url,$eid,$username,$query,$post,$response);
$rid = "test_user";
$rule_name = "foo";
$ruleset = "a144x132";
$eid = time;
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();
$r = Kynetx::Test::configure();
$session = Kynetx::Test::gen_session($r,$rid);
$anon = Kynetx::Persistence::KEN::get_ken($session,$rid);

$dn = "http://$platform/login";


$username =  $DICTIONARY[rand(@DICTIONARY)];
chomp($username);

$password =  $DICTIONARY[rand(@DICTIONARY)];
chomp($password);

my $root_env = Kynetx::Test::gen_root_env($my_req_info,$rule_env,$session);

$description = "Is root env";
$result = Kynetx::Modules::PCI::pci_authorized($my_req_info,$root_env,$session,$rule_name,"foo",[]);
is($result,1,$description);
$test_count++;




##################################### Begin Login portal
Log::Log4perl->easy_init($DEBUG);

# get a clean ua
$ua = LWP::UserAgent->new;
$ua->max_redirect(1);

my $portal_redirect = "http://$platform/blue/event/web/redirect_catcher/a144x175/";
Kynetx::Modules::PCI::add_oauth_callback($my_req_info,$root_env,$session,$rule_name,"foo",[$d_eci,$portal_redirect]);
$result = Kynetx::Modules::PCI::list_callback($my_req_info,$root_env,$session,$rule_name,"foo",[$d_eci]);
$logger->debug("Developer: $d_eci");
$logger->debug("Developer key: $dev_key");

$logger->debug("Callbacks defined: ", sub {Dumper($result)});


$description = "Test username available";
$query = {
  "username" => $username
};
$base_url = $dn . "/available";

$logger->debug("URL: $base_url");
$response = $ua->post($base_url,$query);
$json = $response->content;
$result = Kynetx::Json::jsonToAst_w($json);
cmp_deeply($result->{'available'},1,$description);
$test_count++;



my $test_user = Kynetx::Test::gen_user($my_req_info,$root_env,$session,$username);
$description = "Create test user";
isnt($test_user,undef,$description);
$test_count++;

####################################
# Set password for test user
Kynetx::Modules::PCI::_set_password($test_user,$password);


$description = "Test username un-available";
$response = $ua->post($base_url,$query);
$json = $response->content;
$result = Kynetx::Json::jsonToAst_w($json);
cmp_deeply($result->{'available'},0,$description);
$test_count++;


$description = "Test login fail";
my $bad_password = "shibboleth";
$post = {
  'user' => $username,
  'pass' => $bad_password
};
$base_url = $dn . "/signin";
$response = $ua->post($base_url,$post);
cmp_deeply($response->code,'401',$description);
$test_count++;

$description = "Test login pass";
$post = {
  'user' => $username,
  'pass' => $password
};
$base_url = $dn . "/signin";
$response = $ua->post($base_url,$post);
cmp_deeply($response->code,'200',$description);
$test_count++;

$description = "Returns token on signin pass";
$expected = {
  'eci' => re(qr/$uuid_re/)
};
$json = $response->content;
$result = Kynetx::Json::jsonToAst_w($json);
cmp_deeply($result,$expected,$description);
$test_count++;
my $test_eci = $result->{'eci'};
$logger->debug("Token: $test_eci");

$description = "Check login status by eci";
$base_url = $dn . "/status";
$post = {
  'eci' => $test_eci
};
$response = $ua->post($base_url,$post);
$json = $response->content;
$result = Kynetx::Json::jsonToAst_w($json);
cmp_deeply($result->{'status'},1,$description);
$test_count++;

$description = "Log an account off";
$base_url = $dn . "/logout";
$ua->post($base_url,$post);
$base_url = $dn . "/status";
$post = {
  'eci' => $test_eci
};
$response = $ua->post($base_url,$post);
$json = $response->content;
$result = Kynetx::Json::jsonToAst_w($json);
cmp_deeply($result->{'status'},0,$description);
$test_count++;


Log::Log4perl->easy_init($INFO);
##################################### End Login portal


sub test_request_url {
  my ($client_id,$response_type,$state,$rd_uri) = @_;
  my $base = Kynetx::Configure::get_config('oauth_server')->{'authorize'};
  my $params;
  if (defined $response_type) {
    $params->{'response_type'} = $response_type;
  }
  if (defined $client_id) {
    $params->{'client_id'} = $client_id;
  }
  if (defined $state){
    $params->{'state'} = $state
  }    
  if (defined $rd_uri) {
    $params->{'redirect_uri'} = $rd_uri;
  }
  return Kynetx::Util::mk_url($base,$params);
}

Kynetx::Test::flush_test_user($test_user,$username);
done_testing($test_count);


1;


