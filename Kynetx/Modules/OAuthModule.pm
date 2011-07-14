package Kynetx::Modules::OAuthModule;
# file: Kynetx/Modules/OAuthModule.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Status qw(:constants);
use HTTP::Response;
use Apache2::Const;

use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

use Kynetx::Session qw(
	process_session
	session_cleanup
);
use Kynetx::Persistence;
use Kynetx::Errors;

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


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $funcs = {};

my $default_actions = {
};

sub get_resources {
    return     {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
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
	my $uri = $r->uri();
	if ($uri =~ m/oauth_callback\/(\w+)\/(\w+)\/(\w+)\/?/    ) {
		$cbrid = $1;
		$version = $2;
		$namespace = $3;
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
 		Kynetx::Errors::raise_error($req_info,'warn',
 			"[OAuthModule] $fail",
 			{
 				'genus' => 'oauth',
 				'species' => 'callback'
 			}
 		);
 		$redirect = "http://$host:$port/ruleset/cb_host/$rid/$version/oauth_error";
	} elsif ($cb_action->{'type'} eq 'redirect') {
		$redirect = $cb_action->{'url'};
		return Apache2::Const::REDIRECT;
	} elsif ($cb_action->{'type'} eq 'raise') {
		my $eventname = $cb_action->{'eventname'};
		my $trid = $cb_action->{'target'};		
		$redirect = "http://$host:$port/ruleset/cb_host/$rid/$version/$eventname";		
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
	$r->content_type('text/html');
	print "<html><head></head><body onload=top.close() href='javascript:void(0)' content='10'>";
	#print "<html><head></head><body>";
	#print '<script src="http://init.kobj.net/js/shared/kobj-static.js" type="text/javascript">';
	print '<script>';
	my $x = Kynetx::Events::process_event($r,'oauth_callback',$eventname,$rid,$eid,$version);
	print '</script>';
	print '<script type="text/javascript">window.open("","_self","");window.opener="x";window.close()</script>';
	#print '<script type="text/javascript">window.open("","_self","");window.opener="x";window.close()</script>';
	#print " $uri -|- $eventname </body></html>";
	print "</body></html>";
	return Apache2::Const::OK;
}

##
#	Use the same format for all OAuth tokens (IE: don't namespace Google tokens by scope)
##
sub store_access_tokens {
	my ($req_info, $rule_env, $session, $namespace, $atokens) = @_;
	my $logger = get_logger();
	my $rid = $req_info->{'rid'};
	my $key = ACCESS_TOKEN_KEY . SEP . $namespace;
	my $r = Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $key, $atokens);
	if (defined $r) {
		$logger->debug("Stored access token $key for $namespace");
	} else {
		$logger->debug("Failed to save access token $key for $namespace")
	}
}

sub get_access_tokens {
	my ($req_info, $rule_env, $session, $namespace) = @_;
	my $logger = get_logger();
	my $rid = $req_info->{'rid'};
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
	$logger->trace("Response: ", sub {Dumper($content)});
    if ( $resp->is_success() ) {
        my $oresp =
          Net::OAuth->response('access token')
          ->from_post_body( $resp->content );
        my $oauth_token        = $oresp->token;
        my $oauth_token_secret = $oresp->token_secret;
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

sub get_auth_request_url {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my ($url);
	my $rid = $req_info->{'rid'};
	my $oauth_config = get_oauth_config($req_info,$rule_env,$session,$rule_name,$function,$args);
	my $endpoints = $oauth_config->{'endpoints'};
	my $namespace = $oauth_config->{'namespace'};
	my $scope = $oauth_config->{'scope'};
	my $request_url = $endpoints->{'request_token_url'};
	my $authorization_url = $endpoints->{'authorization_url'};
	my $cbaction = get_callback_action($req_info,$session,$namespace,$args);
    my $tokens = get_consumer_tokens( $req_info, $rule_env, $session, $namespace );
    my $callback = make_callback_url($req_info,$namespace);
    my $request_tokens = get_request_tokens($tokens,$callback,$request_url);
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

sub add_tokens {
	my ($old,$new) = @_;
	foreach my $key (keys %$new) {
		$old->{$key} = $new->{$key};
	}
	return $old;
}

sub get_request_tokens {
	my ($tokens,$callback,$request_url) = @_;
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
    
	$request->sign();
    my $surl = $request->to_url();
    $logger->debug( "Request token url: ", $surl );

    my $ua   = LWP::UserAgent->new();
    my $resp = $ua->request( GET $surl);
    
    $logger->trace("Resp: ", sub {Dumper($resp)});

    if ( $resp->is_success() ) {
        my $oresp =
          Net::OAuth->response('request token')
          ->from_post_body( $resp->content );
        my $oauth_token        = $oresp->token;
        my $oauth_token_secret = $oresp->token_secret;
        return {
        	'oauth_token' => $oauth_token,
        	'oauth_token_secret' => $oauth_token_secret
        };
    }
}

sub make_callback_url {
    my ( $req_info, $namespace ) = @_;
    my $logger = get_logger();
    my $rid     = $req_info->{'rid'};
    my $version = $req_info->{'rule_version'} || 'prod';
    my $caller  = $req_info->{'caller'} || 'dummy';
    my $host    = Kynetx::Configure::get_config('EVAL_HOST');
    my $port    = Kynetx::Configure::get_config('KNS_PORT') || 80;
    my $handler = CALLBACK;
    my $callback = "http://$host:$port/ruleset/$handler/$rid/$version/$namespace";
    $logger->debug( "OAuth callback url: ", $callback );
    return $callback;    
}


sub get_consumer_tokens {
	my ( $req_info, $rule_env, $session, $namespace ) = @_;
	my $logger = get_logger();
	my $rid    = $req_info->{'rid'};
	my $consumer_tokens;
	unless ( $consumer_tokens = Kynetx::Keys::get_key($req_info, $rule_env, $namespace) ) {
        my $ruleset =
          Kynetx::Repository::get_rules_from_repository( $rid, $req_info );
        $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{$namespace};
		Kynetx::Keys::insert_key($req_info, $rule_env, $namespace, $consumer_tokens);
    }
    return ($rule_env,$consumer_tokens);
	
}

sub get_callback_action {
	my($req_info,$session,$namespace,$args) = @_;
	my $logger = get_logger();
	my $rid = $req_info->{'rid'};
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
	my $rid = $req_info->{'rid'};
	my $key = CALLBACK_ACTION_KEY . SEP . $namespace;
	Kynetx::Persistence::delete_persistent_var("ent", $rid, $session, $key);		
}

sub get_oauth_config {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $oauth_service = $args->[0];
	my $config = {
		'namespace' => $oauth_service
	};
	$logger->debug("Get OAuth Request URL for $oauth_service");
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
	
	my $scope = get_oauth_scope($req_info,$rule_env,$session,$rule_name,$function,$args);
	$config->{'scope'} = $scope;
	
	return $config;
	
}

sub get_oauth_scope {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	# haven't implemented scopes yet
	return undef;
}

sub get_oauth_urls {
	my ($oauth_service) = @_;
	my $logger = get_logger();
	my $config = Kynetx::Configure::get_config("OAUTH");
	return undef unless (defined $config->{$oauth_service});
	return $config->{$oauth_service}->{'urls'}	
}


sub run_function {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $f = $funcs->{$function};
    if (defined $f) {
     	return $f->($req_info,$rule_env,$session,$rule_name,$function,$args);
    } else {
    	$logger->warn("Function $function not found in module PDS");
    }

    return undef;
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
	my $rid = $req_info->{'rid'};
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
