package Kynetx::Modules::OAuthModule;
# file: Kynetx/Modules/OAuthModule.pm
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
use strict;
#use warnings;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Status qw(:constants);
use HTTP::Response;
use Apache2::Const qw(HTTP_BAD_REQUEST OK REDIRECT);
use APR::URI;
use URI::Escape;

use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

use Kynetx::Session qw(
	process_session
	session_cleanup
);
use Kynetx::Persistence;
use Kynetx::Rids qw/:all/;
use Kynetx::Errors;
use Kynetx::Modules::HTTP;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	SEP
	CALLBACK_ACTION_KEY
	oauth_callback_handler
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant SEP => "##";
use constant CALLBACK_ACTION_KEY => "__callback_action";
use constant CALLBACK => "oauth_callback";
use constant OAUTH_CONFIG_KEY => "oauth_config";
use constant ACCESS_TOKEN_KEY => "oauth_access_token";
use constant OAUTH_REDIRECT => "oauth_redirect";
use constant OAUTH2 => "oauth2";


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $funcs = {};

my $default_actions = {
	'post' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_opost,
		'after'  => []
	},
	'put' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_oput,
		'after'  => []
	},
	'get' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_oget,
		'after'  => []
	},
	'head' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_ohead,
		'after'  => []
	},
	'delete' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_odelete,
		'after'  => []
	},
	'patch' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_opatch,
		'after'  => []
	},
	'delete_token' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&delete_token,
		'after'  => []
	},
	'authorize_facebook_dialog' => {
		'js' =><<EOF,
function(uniq, cb, config, selector) {
  \$K.kGrowl.defaults.header = "<p id='KOBJ_oauthmodule_facebook_header'>Authorize Facebook Access</p>";
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  
  if (selector) {
  	console.log("Sel: " + selector);
  	\$K(selector).html(KOBJ_oauthmodule_facebook_notice);
  } else {
  	\$K.kGrowl(KOBJ_oauthmodule_facebook_notice);
  	if (\$K('body').popover) {
  		console.log("Bootstrap is available");
  		\$K("#KOBJ_oauthmodule_facebook_notice_appname").wrap("<strong />");
  		\$K("#KOBJ_oauthmodule_facebook_notice_rid").addClass("muted");
  		\$K("#KOBJ_oauthmodule_facebook_notice_yes").addClass("btn btn-primary btn-small");
  		\$K("#KOBJ_oauthmodule_facebook_notice_no").addClass("btn btn-warning btn-small");
  	} else {
  		console.log("Bootstrap not found");
  	}
  }
  
  cb();
}
EOF
		'before' => \&auth_facebook_dialog,
		'after'  => []
	},
};

sub get_resources {
    return     {};
}
sub get_actions {
	my $logger = get_logger();
	$logger->trace("OAuthModule Actions: ", sub {Dumper(keys %$default_actions)});
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}

sub do_oget {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $function = 'GET';
	my $rule_name = '__action__';
	my $v = $vars->[0] || '__dummy';
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	$oauth_config = set_config_from_action($config,$oauth_config,$v);
	return protected_resource_request($req_info,$rule_env,$session,$rule_name,$function,
		$oauth_config, $args)
}
$funcs->{'get'} = \&protected_resource_request;

sub do_opost {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $function = 'POST';
	my $rule_name = '__action__';
	my $v = $vars->[0] || '__dummy';
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	$oauth_config = set_config_from_action($config,$oauth_config,$v);
	return protected_resource_request($req_info,$rule_env,$session,$rule_name,$function,
		$oauth_config, $args)
}
$funcs->{'post'} = \&protected_resource_request;


sub do_ohead {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $function = 'HEAD';
	my $rule_name = '__action__';
	my $v = $vars->[0] || '__dummy';
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	$oauth_config = set_config_from_action($config,$oauth_config,$v);
	return protected_resource_request($req_info,$rule_env,$session,$rule_name,$function,
		$oauth_config, $args)
}
$funcs->{'head'} = \&protected_resource_request;

sub do_oput {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $function = 'PUT';
	my $rule_name = '__action__';
	my $v = $vars->[0] || '__dummy';
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	$oauth_config = set_config_from_action($config,$oauth_config,$v);
	return protected_resource_request($req_info,$rule_env,$session,$rule_name,$function,
		$oauth_config, $args)
}
$funcs->{'put'} = \&protected_resource_request;

sub do_odelete {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $function = 'DELETE';
	my $rule_name = '__action__';
	my $v = $vars->[0] || '__dummy';
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	$oauth_config = set_config_from_action($config,$oauth_config,$v);
	return protected_resource_request($req_info,$rule_env,$session,$rule_name,$function,
		$oauth_config, $args)
}
$funcs->{'delete'} = \&protected_resource_request;

sub do_opatch {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $function = 'PATCH';
	my $rule_name = '__action__';
	my $v = $vars->[0] || '__dummy';
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	$oauth_config = set_config_from_action($config,$oauth_config,$v);
	return protected_resource_request($req_info,$rule_env,$session,$rule_name,$function,
		$oauth_config, $args)
}
$funcs->{'patch'} = \&protected_resource_request;

sub has_token {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	my $atokens = get_access_tokens($req_info, $rule_env, $session, $oauth_service, $oauth_config);
	$logger->trace("Atokens: ", sub {Dumper($atokens)});
	if (defined $atokens) {
		if (defined $atokens->{'access_token_secret'} && $atokens->{'access_token_secret'} ne '') {
			return 1;
		}
	} 
	return 0;
}
$funcs->{'has_token'} = \&has_token;

sub has_oauth2_token {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $logger = get_logger();
	my $rid = get_rid($req_info->{'rid'});
	my $namespace = $args->[0];	    		
	my $key = OAUTH2 . SEP . $namespace;
	my $token = Kynetx::Persistence::get_persistent_var("ent",$rid, $session, $key);
	$logger->debug("Namespace: $namespace  Key: $key  Token: $token");
	if (defined $token) {
		return 1;
	}
	return 0;
}
$funcs->{'has_oauth2_token'} = \&has_oauth2_token;


sub get_oauth2_token {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $rid = get_rid($req_info->{'rid'});
	my $logger = get_logger();
	my $namespace = $args->[0];	    		
	my $key = OAUTH2 . SEP . $namespace;
	my $token = Kynetx::Persistence::get_persistent_var("ent",$rid, $session, $key);
	#$logger->debug("Namespace: $namespace  Key: $key  Token: $token");
	return $token;
}
$funcs->{'get_oauth2_token'} = \&get_oauth2_token;

sub get_token {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	my $atokens = get_access_tokens($req_info, $rule_env, $session, $oauth_service, $oauth_config);
	return $atokens;
}
$funcs->{'_get_token'} = \&get_token;

sub delete_token {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	my $rid = get_rid($req_info->{'rid'});
	my $key = ACCESS_TOKEN_KEY . SEP . $oauth_service;
	$logger->debug("Delete token request: $key");
	Kynetx::Persistence::delete_persistent_var("ent",$rid, $session, $key);	
	return undef;
}


sub set_config_from_action{
	my ($aconfig,$oconfig,$v) = @_;
	if (defined $aconfig->{'params'}) {
		$oconfig->{'params'} = $aconfig->{'params'};
	}
	if (defined $aconfig->{'body'}) {
		$oconfig->{'body'} = $aconfig->{'body'};
	}
	if (defined $aconfig->{'headers'}) {
		$oconfig->{'headers'} = $aconfig->{'headers'};
	}
	if (defined $aconfig->{'response_headers'}) {
		$oconfig->{'response_headers'} = $aconfig->{'response_headers'};
	}
	$oconfig->{'__evar__'} = $v;
	return $oconfig;
}

sub get_auth_request_url {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $logger = get_logger();
	my ($url);
	my $fail = undef;
	my $rid = get_rid($req_info->{'rid'});	
	my $extra_params = $oauth_config->{'extra_params'};
	my $endpoints = $oauth_config->{'endpoints'};
	my $namespace = $oauth_config->{'namespace'};
	my $request_url = $endpoints->{'request_token_url'};
	my $authorization_url = $endpoints->{'authorization_url'};
	my $cbaction = get_callback_action($req_info,$session,$namespace,$args);
    my $tokens = get_consumer_tokens( $req_info, $rule_env, $session, $namespace );
    my $callback = make_callback_url($req_info,$namespace, $args);
    my $request_tokens = get_request_tokens($tokens,$callback,$request_url,$extra_params);
    if (Kynetx::Errors::mis_error($request_tokens)) {
 		Kynetx::Errors::raise_error($req_info,'warn',
 			"[OAuthModule] " . $request_tokens->{'DEBUG'},
 			{
 				'genus' => 'oauth',
 				'species' => 'callback'
 			}
 		);
 		return undef;
	}
	$tokens = add_tokens($tokens,$request_tokens);
    my $ent_config_key = OAUTH_CONFIG_KEY . SEP . $namespace;
    # Need the token secret for the callback
    $oauth_config->{'oauth_token_secret'} = $tokens->{'oauth_token_secret'};
    $oauth_config->{'callback'} = $callback;
    Kynetx::Persistence::save_persistent_var("ent", $rid, $session, $ent_config_key, $oauth_config);
    $url = $authorization_url. '?oauth_token=' . $request_tokens->{'oauth_token'} . '&hd=default';
	return $url;	
}
$funcs->{'get_auth_url'} = \&get_auth_request_url;

sub auth_facebook_dialog {
	my ($req_info,$rule_env,$session,$config,$mods,$args, $vars)  = @_;
	my $rid = get_rid($req_info->{'rid'});
	my $ruleset_name = $req_info->{"$rid:ruleset_name"};
	my $name = $req_info->{"$rid:name"};
	my $author = $req_info->{"$rid:author"};
	my $description = $req_info->{"$rid:description"};
	my $auth_url = get_facebook_auth_url($req_info,$rule_env,$session,$config,$mods,$args, $vars);
	
	my $msg =  <<EOF;
<div id="KOBJ_oauthmodule_facebook_notice">
<p id="KOBJ_oauthmodule_facebook_notice_rid_info">The application 
<span id="KOBJ_oauthmodule_facebook_notice_appname">$name</span> (<span id="KOBJ_oauthmodule_facebook_notice_rid">$rid</span>) from 
$author is requesting that you authorize Facebook to share your Facebook information</p>
<blockquote id="KOBJ_oauthmodule_facebook_notice_rid_desc"><b>Description:</b>$description</blockquote>
<p id="KOBJ_oauthmodule_facebook_notice_rid_request">
The application will not have access to your login credentials at Facebook, 
but will have access to a token that will allow it to make requests on Facebook on your behalf.  
If you click "Take me to Facebook" below, you will taken to Facebook and asked to authorize this 
application.  You can cancel at that point or now by clicking "No Thanks" below.  
Note: if you cancel, this application may not work properly. 
After you have authorized this application, you will be redirected back to this page.</p>
<div>
	<a id="KOBJ_oauthmodule_facebook_notice_yes" href="$auth_url">Take me to Facebook</a>
	<a id="KOBJ_oauthmodule_facebook_notice_no" href="#" onclick="javascript:KOBJ.close_notification('#KOBJ_oauthmodule_facebook_notice');return false;">No Thanks!</a>
</div>
EOF
	
	my $js =  Kynetx::JavaScript::gen_js_var('KOBJ_oauthmodule_facebook_notice',
		   Kynetx::JavaScript::mk_js_str($msg));

	return $js
	
	
}


sub make_facebook_callback {
    my ( $req_info, $namespace, $config ) = @_;
    my $logger = get_logger();
    my $rid     = get_rid($req_info->{'rid'});
    my $version = $req_info->{'rule_version'} || 'prod';
    my $host    = Kynetx::Configure::get_config('EVAL_HOST');
    my $port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
    my $handler = "oauth_facebook";
    my $protocol = 'http';
    if (defined $config) {
    	if ($config->{'use_https'} || $config->{'secure'}) {
    		$protocol = 'https';
    		$port = Kynetx::Configure::get_config('KNS_SECURE_PORT') || 443;
    	}
    }
    my $callback = uri_escape_utf8("$protocol://$host:$port/ruleset/$handler/$rid/$version/$namespace");
    $logger->debug( "OAuth callback url: ", $callback );
    return $callback;    
}




sub facebook_auth_url {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $logger = get_logger();
	my ($url);
	my $fail = undef;
	my $rid = get_rid($req_info->{'rid'});	

}


sub get_facebook_auth_url {
	my ($req_info,$rule_env,$session,$config,$mods,$args, $vars)  = @_;
    my $rid     = get_rid($req_info->{'rid'});
	my $logger=get_logger();
	#$logger->debug("conf: ", sub {Dumper($config)});
	#$logger->debug("mod: ", sub {Dumper($mods)});
	#$logger->debug("arg: ", sub {Dumper($args)});
	#$logger->debug("var: ", sub {Dumper($vars)});
	my $caller  = $req_info->{'caller'} || 'dummy';
	
	my ($url,$scope,$namespace,$token,$redirect,$oauth_access_url);
	if (defined $config->{"request_token_url"}) {
		$url = $config->{"request_token_url"};
	} else {
		$url = "http://www.facebook.com/dialog/oauth";
	}
	if (defined $config->{"scope"}) {
		$scope = $config->{"scope"};
	} else {
		$url = "read_stream";
	}
	if (defined $config->{"namespace"}) {
		$namespace = $config->{"namespace"};
	} else {
		$namespace = "facebook";
	}
	if (defined $config->{"client_id"}) {
		$token = $config->{"client_id"};
	} else {
		my $tokens = get_consumer_tokens( $req_info, $rule_env, $session, $namespace );
		$logger->debug("$namespace : ", sub {Dumper($tokens)});
		$token = $tokens->{"consumer_key"} || $tokens->{"client_id"};
	}
	if (defined $config->{"redirect"}) {
		$redirect = $config->{"redirect"}
	} else {
		$redirect = $caller;
	}
	
	if (defined $config->{"access_url"}) {
		$oauth_access_url = $config->{"access_url"};
	} else {
		$oauth_access_url = 'https://graph.facebook.com/oauth/access_token?';
	}
	my $oid = MongoDB::OID->new();
    my $state = $oid->to_string();
	my $callback= make_facebook_callback( $req_info, $namespace, $config );
	my $ent_config_key = OAUTH_CONFIG_KEY . SEP . $namespace;
	my $eci = Kynetx::Persistence::KToken::get_token($session,$rid)->{'ktoken'};
	my $key = OAUTH_REDIRECT . SEP . $namespace;
	my $struct = {
		$state => $redirect,
		'access_url' => $oauth_access_url,
		'callback' => $callback
	};
	Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $key, $struct);
	Kynetx::Persistence::save_persistent_var("app",$rid, $session, $state, $eci);
	
	#$logger->debug("Saved OAuth request origin: ", sub {Dumper($struct)});
	#$logger->debug("ECI: ", sub {Dumper($eci)});
	
	my $aurl = $url . '?client_id=' . $token . "&redirect_uri=" . $callback . "&state=" . $state . "&scope=" . $scope;
	return $aurl;
	
}


# callback method for facebooks pseudo OAuth 2.0 
sub facebook_callback_handler {
	my ( $r, $method, $rid, $eid ) = @_;
	my $logger = get_logger();
	my ($cbrid,$version,$fail);
	my @junk = ();
	my $session = Kynetx::Session::process_session($r);
	$logger->debug("\n-----------------------OAuth Callback ($method)--------------------------");
	my $req_info = Kynetx::Request::build_request_env( $r, $method, $rid );
	my $rule_env = Kynetx::Environments::empty_rule_env();
    my $host    = Kynetx::Configure::get_config('EVAL_HOST');
    my $port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
    my $protocol = "http";
    my $uri = $r->uri();
    my @elements = split(/\//,$uri);
    my $namespace = pop @elements;
    #$logger->debug("Namespace: $namespace", sub {Dumper(@elements)});
  if ($uri =~ m#http://#) {
		$port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
		$protocol = "http";
	} elsif ($uri =~ m#https://#) {
		$protocol = 'https';
    $port = Kynetx::Configure::get_config('KNS_SECURE_PORT') || 443;
	}
	my $key = OAUTH_REDIRECT . SEP . $namespace;
	#$logger->debug("redirect key: $key");
	my $code  = $req_info->{'code'};
	my $state = $req_info->{'state'};
	my $ent_cache = Kynetx::Persistence::get_persistent_var("ent", $rid, $session, $key);
	my $redirect = $ent_cache->{$state};
	if (defined $redirect) {
		my $oauth_access_url = $ent_cache->{'access_url'};	
		my $callback = 	$ent_cache->{'callback'};
		my $eci = Kynetx::Persistence::get_persistent_var("app", $rid, $session, $state);
		Kynetx::Persistence::delete_persistent_var("app", $rid, $session, $state);
		Kynetx::Persistence::delete_persistent_var("ent", $rid, $session, $key);				
	    my $consumer_tokens = get_consumer_tokens( $req_info, $rule_env, $session, $namespace );
	    my $secret = $consumer_tokens->{'consumer_secret'};
	    my $client_id = $consumer_tokens->{'client_id'} || $consumer_tokens->{'consumer_key'};
	    
	    my $token_request = $oauth_access_url;
	    $token_request .= "client_id=" . $client_id;
	    $token_request .= "\&redirect_uri=". $callback;
	    $token_request .= "\&client_secret=" . $secret;
	    $token_request .= "\&code=" . $code;
		
		my $ua = LWP::UserAgent->new();
	    my $resp = $ua->request( GET $token_request);
	    my $content = $resp->decoded_content();
		
	    if ( $resp->is_success() ) {
	    	my $content = $resp->content();
	    	my @pairs = split(/&/,$content);
	    	my $params;
	    	foreach my $parm (@pairs) {
	    		my ($key,$value) = split(/=/,$parm);
	    		$params->{$key} = $value;
	    	}
	    	my $fb_token = $params->{'access_token'};
	    	#$logger->debug("TOKEN: $fb_token ###################");
	    	if (defined $fb_token) {
	    		my $key = OAUTH2 . SEP . $namespace;
	    		Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $key, $fb_token);
	    	}
	    } else {
	    	$logger->debug("Failed response: ", sub {Dumper($resp)});
	    	return Kynetx::Errors::merror("Request access token failure: $content");
	    }
		push(@junk,$code);
		push(@junk,$state);
		push(@junk,$redirect);
	    push(@junk,$secret);		
		push(@junk,$eci);
		push(@junk,$token_request);
		$r->headers_out->set(Location => $redirect);
		return Apache2::Const::REDIRECT;		
	} else {
		$logger->warn("In facebook token request returned <state> not equal to requested state");
		return Apache2::Const::HTTP_BAD_REQUEST;
	}
	
	Kynetx::Util::page_dump($r,$req_info,$session,@junk);
	return Apache2::Const::OK;
}

sub oauth_callback_handler {
	my ( $r, $method, $rid, $eid ) = @_;
	my $logger = get_logger();
	my ($cbrid,$version,$namespace,$fail);
	$logger->debug("\n-----------------------OAuth Callback ($method)--------------------------");
	my $session = Kynetx::Session::process_session($r);
	my $req_info = Kynetx::Request::build_request_env( $r, $method, $rid );
	my $rule_env = Kynetx::Environments::empty_rule_env();
    my $host    = Kynetx::Configure::get_config('EVAL_HOST');
    my $port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
    my $protocol = "http";
	my $uri = $r->uri();
	if ($uri =~ m/oauth_callback\/(\w+)\/(\w+)\/(\w+)\/?/    ) {
		$cbrid = $1;
		$version = $2;
		$namespace = $3;
	}
  if ($uri =~ m#http://#) {
		$port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
		$protocol = "http";
	} elsif ($uri =~ m#https://#) {
		$protocol = 'https';
    	$port = Kynetx::Configure::get_config('KNS_SECURE_PORT') || 443;
	}
	my $key = CALLBACK_ACTION_KEY . SEP . $namespace;
	my $tokens = get_consumer_tokens( $req_info, $rule_env, $session, $namespace );
	my $auth_tokens = get_auth_tokens($req_info);
	my $atoken = $auth_tokens->{'oauth_token'};
	my $verifier = $auth_tokens->{'oauth_verifier'};
	my $ent_config_key = OAUTH_CONFIG_KEY . SEP . $namespace;
	my $cb_action    = Kynetx::Persistence::get_persistent_var("ent", $rid, $session, $key);
	my $oauth_config = Kynetx::Persistence::get_persistent_var("ent", $rid, $session, $ent_config_key);
	
	if (defined $atoken && defined $verifier) {
		$logger->debug("Callback handler $method processed request for $namespace with token = ",
			$atoken, " and verifier $verifier",);
		$tokens = add_tokens($tokens,$auth_tokens);
		my $endpoint = $oauth_config->{'endpoints'}->{'access_token_url'};
		my $token_secret = $oauth_config->{'oauth_token_secret'};
		$tokens = add_tokens($tokens,{'oauth_token_secret' => $token_secret});
		my $access_tokens = request_access_tokens($req_info, $rule_env, $session, $namespace, $tokens, $endpoint);
		if (Kynetx::Errors::mis_error($access_tokens)) {
			$fail = $access_tokens->{'DEBUG'};
		} else {
			store_access_tokens($req_info, $rule_env, $session, $namespace, $access_tokens);
			post_process_access_tokens($req_info, $rule_env, $session, $namespace, $access_tokens);					
		}
	} else {
		# Callback was not authorized
		$fail = "No verification token from OAuth authority";
	}
  
  	Kynetx::Persistence::delete_persistent_var("ent", $rid, $session, $key);
	Kynetx::Persistence::delete_persistent_var("ent", $rid, $session, $ent_config_key);
	my $redirect;
 	if (defined $fail){
 		$logger->debug("Make redirect-------------------------------");
 		if ($host eq "127.0.0.1") {
 			my $s = $r->server();
 			$port = "8082";#$s->port;
 			$host = $r->hostname;
 		}
 		
 		my $base = "$protocol://$host:$port/ruleset/cb_host/$rid/$version/oauth_error";
 		my $p = {'error' => "\'$fail\'"};
 		$redirect = Kynetx::Util::mk_url($base,$p);
 		$logger->debug("Redirect: $redirect");
	} elsif ($cb_action->{'type'} eq 'redirect') {
		$redirect = $cb_action->{'url'};
		#return Apache2::Const::REDIRECT;
	} elsif ($cb_action->{'type'} eq 'raise') {
		my $eventname = $cb_action->{'eventname'};
		my $trid = $cb_action->{'target'};		
		$redirect = "$protocol://$host:$port/ruleset/cb_host/$rid/$version/$eventname";		
	} else {
		$redirect = $req_info->{'caller'} || ".";
	}
	$r->headers_out->set(Location => $redirect);
	return Apache2::Const::REDIRECT;
	
}

sub callback_host {
	my ( $r, $method, $rid, $eid ) = @_;
	my $logger = get_logger();	
	$logger->debug("\n-----------------------Callback Host ($method)--------------------------");
	my $session = Kynetx::Session::process_session($r);
	my $req_info = Kynetx::Request::build_request_env( $r, $method, $rid );
	
	my $rule_env = Kynetx::Environments::empty_rule_env();
	my $eventname;
	my $version;
	my $uri = $r->uri();
	if ($uri =~ m/\/(\w+)\/(\w+)$/) {
		$version = $1;
		$eventname = $2;
	}
	my $mode = Kynetx::Configure::get_config("RUN_MODE");
	my $servers = Kynetx::Configure::get_config($mode);
	my $kns_port = $servers->{"KNS_PORT"};
	my $s = $r->server();
	my $port = $s->port;
	my $n = $s->server_hostname();
	if (defined $kns_port) {
		$kns_port = ':' . $kns_port;
	} else {
		$kns_port = '';
	}
	my $init_host = $servers->{"INIT_HOST"} . $kns_port;
	my $cb_host = $servers->{"CB_HOST"} . $kns_port;
	my $eval_host = $servers->{"EVAL_HOST"} . $kns_port;
	my $krl_host = $servers->{"KRL_HOST"} . $kns_port;
	
	my $sconfig = {
		'eval_host' => $eval_host,
		'callback_host' => $cb_host,
		'init_host' => $init_host,
		
	};
	my $stag = {
		'init' => $sconfig,
		"$rid:kynetx_app_version" => $version,
		"rids" => [$rid],
		"$rid:site_tag" => "true"		
	};
	
	my $json = Kynetx::Json::encode_json($stag);
	
	$r->content_type('text/html');
	print "<html><head></head><body onload=top.close() href='javascript:void(0)' content='10'>";
	#print "<html><head></head><body>";
	print '<script type="text/javascript">window.open("","_self","");window.opener="x";window.close()</script>';
	print '<script type="text/javascript">';
	print 'var d = document;';
	print 'var s = d.createElement("script");';
	print 's.text=\'KOBJ_config=' . $json . '\';';
	print 'd.body.appendChild(s);';
	print 'var l = d.createElement("script");';
	print 'l.src=\'http://init.kobj.net/js/shared/kobj-static.js\';';
	print 'd.body.appendChild(l);';
	print '</script>';
	print "</body></html>";
	return Apache2::Const::OK;
}

##
#	Use the same format for all OAuth tokens (IE: don't namespace Google tokens by scope)
##
sub store_access_tokens {
	my ($req_info, $rule_env, $session, $namespace, $atokens) = @_;
	my $logger = get_logger();
	my $rid = get_rid($req_info->{'rid'});
	my $key = ACCESS_TOKEN_KEY . SEP . $namespace;
	my $r = Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $key, $atokens);
	if (defined $r) {
		$logger->debug("Stored access token $key for $namespace");
		$logger->trace("Tokens: ", sub {Dumper($atokens)});
	} else {
		$logger->debug("Failed to save access token $key for $namespace")
	}
}


sub get_access_tokens {
	my ($req_info, $rule_env, $session, $namespace, $oauth_config) = @_;
	my $logger = get_logger();
	my $passed_tokens = $oauth_config->{'access_tokens'};
	if (defined $passed_tokens) {
		$logger->debug("Using tokens from parameters");
		return $passed_tokens
	}
	my $rid = get_rid($req_info->{'rid'});
	my $key = ACCESS_TOKEN_KEY . SEP . $namespace;
	my $value = Kynetx::Persistence::get_persistent_var("ent", $rid, $session, $key);
	return $value;
}

##
#	Requires:
#		consumer_key		: ruleset 		-> $tokens
#		consumer_secret		: ruleset 		-> $tokens
#		oauth_token			: $r	  		-> $tokens
#		oauth_secret		: $oauth_config	-> $tokens
#		verifier			: $r			-> $tokens
#		access_token_url	: $oauth_config (endpoints)
#
##
sub request_access_tokens {
	my ($req_info, $rule_env, $session, $namespace, $tokens, $endpoint) = @_;
	my $logger = get_logger();
	
	my $request;
	
	eval {
		$request = Net::OAuth->request("access token")->new(
			'consumer_key'    => $tokens->{'consumer_key'},
	        'consumer_secret' => $tokens->{'consumer_secret'},
			'token'           => $tokens->{'oauth_token'},
			'token_secret'    => $tokens->{'oauth_token_secret'},
			'verifier'        => $tokens->{'oauth_verifier'},
			'request_url'     => $endpoint,
			'request_method'  => 'GET',
			'signature_method' => 'HMAC-SHA1',
			'timestamp'        => time(),
			'nonce'            => nonce(),
		);
	};
	if ($@) {
    	return Kynetx::Errors::merror("Request access token failure: " . $@);		
	}
	$request->sign();
	my $surl = $request->to_url();
	my $ua = LWP::UserAgent->new();
    my $resp = $ua->request( GET $surl);
    my $content = $resp->decoded_content();
	
    if ( $resp->is_success() ) {
        my $oresp;
        my $oauth_token;
        my $oauth_token_secret;
        eval {
        	$oresp = Net::OAuth->response('access token')->from_post_body( $resp->content );
            $oauth_token        = $oresp->token;
            $oauth_token_secret = $oresp->token_secret;
        };
        if ($@) {
        	$logger->debug("OAuthModule parsing error: $@");
        	$logger->debug("Response: ", sub {Dumper($content)});
        	my @pairs = split '&', $resp->content;
        	$logger->trace("Pairs: ", sub {Dumper(@pairs)});
        	my $parms = Kynetx::Util::from_pairs(\@pairs);
        	$oauth_token        = $parms->{'oauth_token'};
        	$oauth_token_secret = $parms->{'oauth_token_secret'};
        }
        return {
	    	'access_token' => $oauth_token,
	    	'access_token_secret' => $oauth_token_secret,
	    	'__content' => $content
        }
    } else {
    	$logger->debug("Failed response: ", sub {Dumper($resp)});
    	return Kynetx::Errors::merror("Request access token failure: $content");
    }
	
}



sub get_auth_tokens {
	my ($req_info) = @_;
	my $logger = get_logger();
	my $token     = $req_info->{'oauth_token'};
	my $verifier  = $req_info->{'oauth_verifier'};
    return {
		'oauth_token' => $token,
		'oauth_verifier' => $verifier
	};
}

sub run_function {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $f = $funcs->{$function};
    if (defined $f) {
     	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
     	return $f->($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args);
    } else {
    	$logger->warn("Function $function not found in module PDS");
    }

    return undef;
}



sub protected_resource_request {
	my ($req_info,$rule_env,$session,$rule_name,$function,$oauth_config, $args) = @_;
	my $logger = get_logger();
	my $namespace = $oauth_config->{'namespace'};
	my $extra_params = $oauth_config->{'extra_params'};
	my $headers = $oauth_config->{'headers'};
	my $url = $oauth_config->{'request_url'};
	my $ctokens = get_consumer_tokens( $req_info, $rule_env, $session, $namespace );
	my $atokens = get_access_tokens($req_info, $rule_env, $session, $namespace, $oauth_config);
	my $preq;
	my $method = uc($function) || 'GET';
	my $request;
	eval {
		$request = Net::OAuth::ProtectedResourceRequest->new(
		'consumer_key'    => $ctokens->{'consumer_key'},
		'consumer_secret' => $ctokens->{'consumer_secret'},
		'token'           => $atokens->{'access_token'},
		'token_secret'    => $atokens->{'access_token_secret'},
		'request_url'     => $url,
		'request_method'  => $method,
		'signature_method' => 'HMAC-SHA1',
		'timestamp'        => time(),
		'nonce'            => nonce(),
	       );
	};
	if ($@) {
		my $v = $oauth_config->{'__evar__'} || '__default__';
		my $e_response = {
				'content' => $@,
				'status_code' => HTTP::Status::RC_UNAUTHORIZED,
				'status_line' => HTTP::Status::status_message(HTTP::Status::RC_UNAUTHORIZED),
				'Content-Type' => 'text/plain',
				'Content-Length' => length($@)
				
		};
    	return $e_response;		
	}
	
	if (defined $extra_params) {
	  $request->extra_params($extra_params);
	}  
	$request->sign();
	my $purl = $request->to_url;
	if ($method eq 'GET') {
		$preq = HTTP::Request->new( GET => $purl );
		$logger->trace("Request: ", sub {Dumper($preq->as_string())});
	} elsif ($method eq 'POST') {
		$preq = HTTP::Request->new( POST => $purl );
		my $content = $oauth_config->{'body'};
		if (defined $content) {
			$preq->content($content);
		}
	} elsif ($method eq 'PUT') {
		$preq = HTTP::Request->new( PUT => $purl );
		my $content = $oauth_config->{'body'};
		if (defined $content) {
			$preq->content($content);
		}
	} elsif ($method eq 'DELETE') {
		$preq = HTTP::Request->new( DELETE => $purl );
	} else {
		$logger->warn("Method ($method) not supported for OAuth Protected Resource Request");
	}
	$logger->trace("Auth header: ",$request->to_authorization_header);
	
	foreach my $k (keys %{$headers}) {
		#$preq->header($k => $headers->{$k});
		if (lc($k) eq 'authorization') {
			$preq->header($k =>$request->to_authorization_header);
			$preq->uri($request->request_url());
		} else {
			$preq->header($k => $headers->{$k});
		}
	}
	
    my $ua   = LWP::UserAgent->new;
    my $response = $ua->simple_request($preq);
    my $v = $oauth_config->{'__evar__'} || '__default__';
    my $resp = Kynetx::Modules::HTTP::make_response_object($response,$v,$oauth_config);
	return $resp->{$v};
}

sub get_oauth_config {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	my $config = {
		'namespace' => $oauth_service
	};
	my $endpoints = get_oauth_urls($oauth_service);
	
	if (defined $endpoints) {
		$logger->trace("OAuth urls for $oauth_service: ", sub {Dumper($endpoints)});
		$config->{"endpoints"} = $endpoints;
	} else {
		# Need to save token url so callback knows what OAuth service to use
		my $opts = $args->[1];
		$logger->debug("Service $oauth_service undefined, check ARGS for config");
		$config->{"endpoints"} = {
			'request_token_url' => $opts->{'request_token_url'},
			'authorization_url' => $opts->{'authorization_url'},
			'access_token_url'	=> $opts->{'access_token_url'}
		}		
	}
	
	if (my $p = get_params($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$config->{'extra_params'} = $p;
	}	
	
	if (my $b = get_body($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$config->{'body'} = $b;
	}
	
	if (my $h = get_headers($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$config->{'headers'} = $h;
	}
	
	if (my $u = get_url($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$config->{'request_url'} = $u;
	}
	
	if (my $rh = get_response_headers($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$config->{'response_headers'} = $rh;
	}

	if (my $rh = get_passed_tokens($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$config->{'access_tokens'} = $rh;
	}

	return $config;
	
}

sub get_passed_tokens {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	
	my $opts = $args->[1];
	if (defined $opts) {
		return $opts->{'access_tokens'};
	} else {
		return undef;
	}
	
}
sub add_tokens {
	my ($old,$new) = @_;
	foreach my $key (keys %$new) {
		$old->{$key} = $new->{$key};
	}
	return $old;
}

sub get_request_tokens {
	my ($tokens,$callback,$request_url,$extras) = @_;
	my $logger = get_logger();
	my $ckey = $tokens->{'consumer_key'};
	my $csecret = $tokens->{'consumer_secret'};
    my $request = Net::OAuth->request("request token")->new(
                     'consumer_key'    => $ckey,
                     'consumer_secret' => $csecret,
                     'request_url'     => $request_url,
                     'request_method'  => 'GET',
                     'signature_method' => 'HMAC-SHA1',
                     'timestamp'        => time(),
                     'nonce'            => nonce(),
                     'callback'         => $callback,
    );
    if (defined $extras) {
    	$request->extra_params($extras);
    }
	$request->sign();
    my $surl = $request->to_url();
    $logger->debug( "Request token url: ", $surl );

    my $ua   = LWP::UserAgent->new();
    my $resp = $ua->request( GET $surl);
    
    $logger->trace("Resp: ", sub {Dumper($resp)});

    if ( $resp->is_success() ) {
        my $oresp;
        my $oauth_token;
        my $oauth_token_secret;
        eval { $oresp =
          Net::OAuth->response('request token')
          ->from_post_body( $resp->content );
        };
        if ($@) {
        	my @pairs = split '&', $resp->content;
        	$logger->trace("Pairs: ", sub {Dumper(@pairs)});
        	my $parms = Kynetx::Util::from_pairs(\@pairs);
        	$oauth_token        = $parms->{'oauth_token'};
        	$oauth_token_secret = $parms->{'oauth_token_secret'};
        } else {
        	$oauth_token        = $oresp->token;
        	$oauth_token_secret = $oresp->token_secret;
        	
        }
        return {
        	'oauth_token' => $oauth_token,
        	'oauth_token_secret' => $oauth_token_secret
        };
        
    } else {
    	my $fail = $resp->code() . "," . $resp->status_line() . "," . $resp->decoded_content();
		return Kynetx::Errors::merror($fail);
    }
}

sub make_callback_url {
    my ( $req_info, $namespace, $args ) = @_;
    my $logger = get_logger();
    my $rid     = get_rid($req_info->{'rid'});
    my $version = $req_info->{'rule_version'} || 'prod';
    my $caller  = $req_info->{'caller'} || 'dummy';
    my $host    = Kynetx::Configure::get_config('EVAL_HOST');
    my $port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
    my $handler = CALLBACK;
    my $protocol = 'http';
    my $opts = $args->[1];
    if (defined $opts) {
    	if ($opts->{'use_https'} || $opts->{'secure'}) {
    		$protocol = 'https';
    		$port = Kynetx::Configure::get_config('KNS_SECURE_PORT') || 443;
    	}
    }
    my $callback = "$protocol://$host:$port/ruleset/$handler/$rid/$version/$namespace";
    $logger->debug( "OAuth callback url: ", $callback );
    return $callback;    
}


sub get_consumer_tokens {
	my ( $req_info, $rule_env, $session, $namespace ) = @_;
	my $logger = get_logger();
	my $rid_info   = $req_info->{'rid'};
	my $consumer_tokens;
	unless ( $consumer_tokens = Kynetx::Keys::get_key($req_info, $rule_env, $namespace) ) {
        my $ruleset =
          Kynetx::Repository::get_rules_from_repository( $rid_info, $req_info );
        $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{$namespace};
		Kynetx::Keys::insert_key($req_info, $rule_env, $namespace, $consumer_tokens);
    }
    return ($rule_env,$consumer_tokens);
	
}


sub get_callback_action {
	my($req_info,$session,$namespace,$args) = @_;
	my $logger = get_logger();
	my $rid = get_rid($req_info->{'rid'});
	my ($eventname,$targetrid,$cbaction);
	my $key = CALLBACK_ACTION_KEY . SEP . $namespace;
	
	my $opts = $args->[1];
	my $caller = $req_info->{'caller'};
	if (defined $opts) {
		if (defined $opts->{'raise_callback_event'}) {
			$eventname = $opts->{'raise_callback_event'};
			if (defined $opts->{'app_id'}) {
				$targetrid = $opts->{'app_id'};
			} else {
				$targetrid = $rid;
			}
			$cbaction = {
				'type' => 'raise',
				'eventname' => $eventname,
				'target' => $targetrid
			};
		} 
	}
	unless (defined $cbaction) {
		#default is to redirect to caller
		$cbaction = {
			'type' => 'redirect',
			'url'  => $caller
		}
	}	
	Kynetx::Persistence::save_persistent_var("ent", $rid, $session, $key, $cbaction);
	return $cbaction;
}

sub clear_callback_action {
	my($req_info,$session,$namespace,$args) = @_;
	my $rid = get_rid($req_info->{'rid'});
	my $key = CALLBACK_ACTION_KEY . SEP . $namespace;
	Kynetx::Persistence::delete_persistent_var("ent", $rid, $session, $key);		
}



sub get_params {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	
	my $opts = $args->[1];
	if (defined $opts) {
		return $opts->{'params'};
	} else {
		return undef;
	}
}


sub get_url {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	
	my $opts = $args->[1];
	if (defined $opts) {
		return $opts->{'url'};
	} else {
		return undef;
	}
}

sub get_body {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	
	my $opts = $args->[1];
	if (defined $opts) {
		return $opts->{'body'};
	} else {
		return undef;
	}
	
}

sub get_headers {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	
	my $opts = $args->[1];
	if (defined $opts) {
		return $opts->{'headers'};
	} else {
		return undef;
	}
	
}

sub get_response_headers {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	
	my $opts = $args->[1];
	if (defined $opts) {
		return $opts->{'response_headers'};
	} else {
		return undef;
	}	
}


sub get_oauth_urls {
	my ($oauth_service) = @_;
	my $logger = get_logger();
	my $config = Kynetx::Configure::get_config("OAUTH");
	return undef unless (defined $config->{$oauth_service});
	return $config->{$oauth_service}->{'urls'}	
}



sub nonce {
    my @a = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
    my $nonce = '';
    for ( 0 .. 31 ) {
        $nonce .= $a[ rand( scalar(@a) ) ];
    }

    return $nonce;
}

##
# Use this to configure any of the existing OAuth implementations
#
##
sub post_process_access_tokens {
	my ($req_info, $rule_env, $session, $namespace, $atokens) = @_;
	my $logger = get_logger();
	$logger->trace("pTokens: ", sub {Dumper($atokens)});
	my $rid = get_rid($req_info->{'rid'});
	if ($namespace eq 'twitter') {
		my $params = Kynetx::Util::body_to_hash($atokens->{'__content'});
		Kynetx::Modules::Twitter::store_access_tokens(
			$rid, 
			$session, 
			$params->{'oauth_token'}, 
			$params->{'oauth_token_secret'}, 
			$params->{'user_id'}, 
			$params->{'screen_name'});
	}
}

1;
