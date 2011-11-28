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
use Test::LongString;
use Test::Deep;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

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
use Kynetx::Rids qw(:all);
use Kynetx::Rules qw(:all);
use Kynetx::Persistence;

use Kynetx::FakeReq qw/:all/;
use Kynetx::Modules::OAuthModule qw/:all/;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = Kynetx::Modules::Twitter::get_predicates();
my @pnames = keys (%{ $preds } );

my $r = Kynetx::Test::configure();

my $rid = 'a144x123';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

$my_req_info->{"$rid:ruleset_name"} = "a144x123";
$my_req_info->{"$rid:name"} = "a144x123";
$my_req_info->{"$rid:author"} = "Phil Windley";
$my_req_info->{"$rid:description"} = "This is a test rule";

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

# Sync session with Browser session
my $sessionid = '39f67cb8de78e8f036f35a795036e787';
my $session = Kynetx::Session::process_session($r,$sessionid);

my $test_count = 0;


my $logger = get_logger();



my($js,$result,$namespace,$expected,$description,$keys);
my $rightnow = Kynetx::Predicates::Time::get_time($my_req_info,'now',[{'timezone'=>'America/Denver'}]);
my $plus4 = Kynetx::Predicates::Time::get_time($my_req_info,'add',["$rightnow",{"hours"=>4}]);
my $plus5 = Kynetx::Predicates::Time::get_time($my_req_info,'add',["$rightnow",{"hours"=>5}]);

my $plus4a = Kynetx::Predicates::Time::get_time($my_req_info,'atom',
    ["$plus4"]);
my $plus5a = Kynetx::Predicates::Time::get_time($my_req_info,'atom',
    ["$plus5"]);
           
# get a random quote
$logger->debug("Get a random quote");
my $rquote = "contactless not, swipe again please";
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
my $quote_url = 'http://www.iheartquotes.com/api/v1/random?max_lines=4&show_permalink=false&show_source=0';
my $qresp = $ua->request(GET $quote_url);
if ($qresp->is_success) {
    $rquote = $qresp->content;
    $rquote =~ s/\s+$//;
}
$rquote = Kynetx::JavaScript::mk_js_str($rquote);
    
# get a random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $what = $DICTIONARY[rand(@DICTIONARY)];
my $who = $DICTIONARY[rand(@DICTIONARY)];
my $where = $DICTIONARY[rand(@DICTIONARY)];
chomp($what);
chomp($where);
chomp($who);
    
#goto ENDY;

### Test with twitter

#my $keys = {'consumer_secret' => '3HNb7NhKuqRIm2BuxKPSg6JYvMtLahvkMt6Std5SO0',
#	    'consumer_key' => 'jPlIPAk1gbigEtonC2yNA'
#	   };
$keys = {'consumer_secret' => 'ePBFOUvdL6N5CBzgVwEhoi5Sc39ZR7GpDoAQzpV25w',
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

$result = Kynetx::Persistence::get_persistent_var('ent',get_rid($my_req_info->{'rid'}),$session,CALLBACK_ACTION_KEY.SEP.$namespace);
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Clear callback";
$expected = undef;
Kynetx::Modules::OAuthModule::clear_callback_action($my_req_info,$session,$namespace,$args);
$result = Kynetx::Persistence::get_persistent_var('ent',get_rid($my_req_info->{'rid'}),$session,CALLBACK_ACTION_KEY.SEP.$namespace);
cmp_deeply($result,$expected,$description);
$test_count++;

$args = ['twitter'];

$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get_auth_url',$args);

$logger->debug("Returns: ", sub {Dumper($result)});
#die;
#done_testing($test_count + int(@pnames));


### Test with google

$keys = {
	'consumer_key' => 'kynetx.com',
   	'consumer_secret' => '6aXgrwSCnpLutnJy0W8Vg5Tq'
  };

# these are google consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'google',
  $keys);
 
# google calendar auth token
my $atoken = {
	'access_token' => '1/xPC6_XCDp4UDrTui9vJR9Jo9uOuZ_TIHjUGxdJ0VV1c',
	'access_token_secret' => 'EQUsSkHPrMPZ-BZ4jotxq_bQ'
};

$args = ['google',{
			'params' =>{
				'scope' => 'https://www.google.com/m8/feeds/'
			}
		}];

$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get_auth_url',$args);
$logger->trace("Auth url: ", $result);

Kynetx::Modules::OAuthModule::store_access_tokens($my_req_info,$rule_env,$session,'google',$atoken);

$description = "Make a google calendar request";
my $purl = 'https://www.google.com/calendar/feeds/default';
$args = ['google', {
		'url' => $purl,
		'headers' => {
			'Content-type'  => 'application/atom+xml',
			#'Content-type'  => 'text/jsonc',
			'GData-Version' => "2.0"
		},
		'params' => {
			'alt' => 'jsonc',
		},
		'response_headers' => ['Location']
		
	}];

$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get',$args);
$logger->debug("Response: ", sub {Dumper($result)});
if (defined $result->{'location'}) {
	my $redirect = $result->{'location'};
	my $uri = URI->new( $redirect ); 
	my %query = $uri->query_form;
	$args->[1]->{'params'}->{'gsessionid'} = $query{'gsessionid'};
	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get',$args);
	
}
cmp_deeply($result->{'status_code'},'200',$description);
$test_count++;


my $body = <<_JSONC_;
{
	"data" : {
		"title" : "$who",
		"details" : $rquote,
		"transparency" : "opaque",
		"status" : "confirmed",
		"location" : "$where",
		"when" : [
			{
				"start" : "$plus4",
				"end"   : "$plus5"
			}
		]
	}
}
_JSONC_
$purl = 'https://www.google.com/calendar/feeds/default/private/full';
$args = ['google', {
		'url' => $purl,
		'headers' => {
			'Content-type'  => 'application/json',
			'GData-Version' => "2.0"
		},
#		'params' => {
#			'gsessionid' => 'hNWGV-MhXJ_OoHh_IiI-NQ'
#		},
		'body' => $body,
		'response_headers' => ['Location', 'header_field_names']
		
	}];



$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'post',$args);
$logger->debug("Response: ", sub {Dumper($result)});
if ($result->{'status_code'} == 302) {
	#$logger->info("Response: ", sub {Dumper($result)});
	my $redirect = $result->{'location'};
	my $uri = URI->new( $redirect ); 
	my %query = $uri->query_form;
	$args->[1]->{'params'}->{'gsessionid'} = $query{'gsessionid'};
	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'post',$args);
	
}
$description = "Insert a new google calendar event";
cmp_deeply($result->{'status_code'},'201',$description);
$test_count++;




my $new_url = $result->{'location'};
my $content = $result->{'content'};
my $jsonc = Kynetx::Json::jsonToAst_w($content);
my $mod_time = Kynetx::Predicates::Time::get_time($my_req_info,'now',[{'timezone'=>'America/Denver'}]);

$jsonc->{'data'}->{'details'} = $jsonc->{'data'}->{'details'} . "--modified at $mod_time";
$content = Kynetx::Json::astToJson($jsonc);

$logger->trace("Changed content: $content");

$purl = $new_url;
$args = ['google', {
		'url' => $purl,
		'headers' => {
			'Content-type'  => 'application/json',
			'GData-Version' => "2.0"
		},
		'params' => {
			'gsessionid' => 'hNWGV-MhXJ_OoHh_IiI-NQ'
		},
		'body' => $content,
		'response_headers' => ['ETag']		
	}];
	
$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'put',$args);
$logger->trace("Response: ", sub {Dumper($result)});
if ($result->{'status_code'} == 302) {
	#$logger->info("Response: ", sub {Dumper($result)});
	my $redirect = $result->{'location'};
	my $uri = URI->new( $redirect ); 
	my %query = $uri->query_form;
	$args->[1]->{'params'}->{'gsessionid'} = $query{'gsessionid'};
	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'post',$args);
	
}
$description = "Update a calendar entry";
cmp_deeply($result->{'status_code'},'200',$description);
$test_count++;



my $etag = $result->{'etag'};


$args = ['google', {
		'url' => $purl,
		'headers' => {
			'Content-type'  => 'application/json',
			'GData-Version' => "2.0",
			'If-Match' => $etag
		},
#		'params' => {
#			'gsessionid' => 'hNWGV-MhXJ_OoHh_IiI-NQ',
#		}
	}];
$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'delete',$args);
if ($result->{'status_code'} == 302) {
	my $redirect = $result->{'location'};
	my $uri = URI->new( $redirect ); 
	my %query = $uri->query_form;
	$args->[1]->{'params'}->{'gsessionid'} = $query{'gsessionid'};
	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'delete',$args);
	
}
$logger->trace("Delete Response: ", sub {Dumper($result)});
if ($result->{'status_code'} == 302) {
	#$logger->info("Response: ", sub {Dumper($result)});
	my $redirect = $result->{'location'};
	my $uri = URI->new( $redirect ); 
	my %query = $uri->query_form;
	$args->[1]->{'params'}->{'gsessionid'} = $query{'gsessionid'};
	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'post',$args);
	
}
$description = "Delete a calendar entry";
cmp_deeply($result->{'status_code'},'200',$description);
$test_count++;



# Generic auth request
my $onamespace = "anon";
$keys = {
	'consumer_key' => 'jPlIPAk1gbigEtonC2yNA',
   	'consumer_secret' => '3HNb7NhKuqRIm2BuxKPSg6JYvMtLahvkMt6Std5SO0'
  };

# these are anonymous consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  $onamespace,
  $keys);
 
# twitter auth token
my $anontoken = {
	'access_token' => '100844323-XqQfRm33tQqp54mmhKCfNF9VIOaxVISrIYTOTXOy',
	'access_token_secret' => 'QdGk4MGc2RiNuD5MHjL5GVk9m1h3SsooGeMWfUQb7f0'
};
#Kynetx::Modules::OAuthModule::store_access_tokens($my_req_info,$rule_env,$session,$onamespace,$anontoken);

my $turl = 'https://api.twitter.com/1/statuses/user_timeline.json';
$args = [$onamespace, {
		'url' => $turl,
		'params' => {
			'include_entities' => 'true',
			'include_rts' => 'true',
			'screen_name' => "kynetx_test",
			'count' => 2
		},
		'access_tokens' => $anontoken
	}];

$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get',$args);
$logger->trace("Response: ", sub {Dumper($result)});
$description = "Make a self contained twitter request";
cmp_deeply($result->{'status_code'},'200',$description);
$test_count++;




### Test with anonymous google tokens
$namespace = 'ganon';
$keys = {
	'consumer_key' => 'kynetx.com',
   	'consumer_secret' => '6aXgrwSCnpLutnJy0W8Vg5Tq'
  };

# these are google consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  $namespace,
  $keys);
 
# google calendar auth token
$anontoken = {
	'access_token' => '1/rf20EYkNxvcqNhFXKvGaIomBHJOwIFZ-D71Yvv96CA8',
	'access_token_secret' => 'WDP5ZXVqMtJWmFuhY5e9cU5C'
};

my $aurl = 'https://www.google.com/m8/feeds/contacts/default/full';
$args = [$namespace, {
		'url' => $aurl,
		'headers' => {
			'Content-type'  => 'application/atom+xml',
			#'Content-type'  => 'text/jsonc',
			'GData-Version' => "2.0"
		},
		'params' => {
			'alt' => 'json'
		},
		'response_headers' => ['Location'],
		'access_tokens' => $anontoken		
	}];

$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get',$args);
$logger->trace("Response: ", sub {Dumper($result)});
$description = "Make a self contained Google Contacts request";
cmp_deeply($result->{'status_code'},'200',$description);
$test_count++;



#if ($result->{'status_code'} eq '302') {
#	my $redirect = $result->{'location'};
#	$args = [$namespace, {
#		'url' => $redirect,
#		'headers' => {
#			'Content-type'  => 'application/atom+xml',
#			#'Content-type'  => 'text/jsonc',
#			'GData-Version' => "2.0"
#		},
##		'params' => {
##			'alt' => 'jsonc'
##		},
#		'response_headers' => ['Location'],
#		'access_tokens' => $anontoken		
#	}];
#	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get',$args);
#	$logger->debug("Response: ", sub {Dumper($result)});
#	
#}

done_testing($test_count);

session_cleanup($session);

1;


