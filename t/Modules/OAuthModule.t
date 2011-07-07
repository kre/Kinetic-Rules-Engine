#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use Test::Deep;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Apache2::Const;
use APR::URI;
use APR::Pool;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Rules qw(:all);
use Kynetx::Persistence;

use Kynetx::FakeReq qw/:all/;
use Kynetx::Modules::OAuthModule qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = Kynetx::Modules::Twitter::get_predicates();
my @pnames = keys (%{ $preds } );

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

$my_req_info->{"$rid:ruleset_name"} = "cs_test";
$my_req_info->{"$rid:name"} = "cs_test";
$my_req_info->{"$rid:author"} = "Phil Windley";
$my_req_info->{"$rid:description"} = "This is a test rule";

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

# Sync session with Browser session
my $sessionid = '39f67cb8de78e8f036f35a795036e787';
my $session = Kynetx::Session::process_session($r,$sessionid);

my $test_count = 0;


my $logger = get_logger();



my($js,$result,$namespace,$expected,$description);

#my $keys = {'consumer_secret' => '3HNb7NhKuqRIm2BuxKPSg6JYvMtLahvkMt6Std5SO0',
#	    'consumer_key' => 'jPlIPAk1gbigEtonC2yNA'
#	   };
my $keys = {'consumer_secret' => 'ePBFOUvdL6N5CBzgVwEhoi5Sc39ZR7GpDoAQzpV25w',
	    'consumer_key' => 'tuSsYBtiUWklyazIbf3oxw'
	   };

# these are twitter consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'twitter',
  $keys);

# these are KRE generic consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'v1.0a',
  $keys);


my $stored_keys = 
 Kynetx::Keys::get_key(
  $my_req_info,
  $rule_env,
  'twitter');

is_deeply($stored_keys, $keys, "Keys got stored right");
$test_count++;

my $urls = Kynetx::Configure::get_config("OAUTH");

my $rtu = $urls->{'twitter'}->{'urls'}->{'request_token_url'};

#$logger->debug("URLS: ",sub {Dumper($urls)});
is($rtu,'https://api.twitter.com/oauth/request_token',"Request Token URL defined for Twitter");
$test_count++;

my $args = ['twitter'];

my $config = Kynetx::Modules::OAuthModule::get_oauth_config($my_req_info,$rule_env,$session,$rule_name,'get_auth_request_url',$args);

cmp_deeply($config->{'endpoints'}->{'request_token_url'},$rtu,"Default Twitter config");
$test_count++;



$args = ['v1.0a',{
  'request_token_url' => 'https://api.twitter.com/oauth/request_token',
  'authorization_url' => 'https://api.twitter.com/oauth/authorize',
  'access_token_url' => 'https://api.twitter.com/oauth/access_token'
}];
$config = Kynetx::Modules::OAuthModule::get_oauth_config($my_req_info,$rule_env,$session,$rule_name,'get_auth_request_url',$args);

cmp_deeply($config->{'endpoints'}->{'request_token_url'},$rtu,"Generic config");
$test_count++;

$description = "Set raise event callback";
$namespace = 'twitter';
$args = [$namespace,{
			'raise_callback_event' => 'RCA',
			'app_id'=>'APPID'}];
$expected = {
				'type' => 'raise',
				'eventname' => 'RCA',
				'target' => 'APPID'
			};
$result = Kynetx::Modules::OAuthModule::get_callback_action($my_req_info,$session,$namespace,$args);

cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Set redirect callback";
$namespace = 'twitter';
$args = [$namespace];
$expected = {
				'type' => 'redirect',
				'url' => 'http://www.windley.com/'
			};
$result = Kynetx::Modules::OAuthModule::get_callback_action($my_req_info,$session,$namespace,$args);

cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Check that the callback has been saved";
$args = [$namespace];

$result = Kynetx::Persistence::get_persistent_var('ent',$my_req_info->{'rid'},$session,CALLBACK_ACTION_KEY.SEP.$namespace);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Clear callback";
$expected = undef;
Kynetx::Modules::OAuthModule::clear_callback_action($my_req_info,$session,$namespace,$args);
$result = Kynetx::Persistence::get_persistent_var('ent',$my_req_info->{'rid'},$session,CALLBACK_ACTION_KEY.SEP.$namespace);
cmp_deeply($result,$expected,$description);
$test_count++;

$args = ['twitter'];

$result = Kynetx::Modules::OAuthModule::get_auth_request_url($my_req_info,$rule_env,$session,$rule_name,'get_auth_request_url',$args);

$logger->debug("Returns: ", sub {Dumper($result)});
done_testing($test_count + int(@pnames));

session_cleanup($session);

1;


