package Kynetx::Predicates::Google::OAuthHelper;

# file: Kynetx/Predicates/Google/OAuthHelper.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);

#use base qw(Net::OAuth::Simple);
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Status qw(:constants);
use HTTP::Response;
use URI::Escape ('uri_escape');
use Encode;

use Kynetx::Session qw(
  session_keys
  session_delete
  session_store
  session_get
);
use Kynetx::Util;
use Kynetx::Memcached qw(check_cache mset_cache);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          get_authorization_message
          get_tokens_by_oauth_token
          get_token
          get_scope_from_token
          store_token
          set_auth_tokens
          get_access_tokens
          get_protected_resource
          trim_tokens
          blast_tokens
          post_protected_resource
          get_consumer_tokens
          make_callback_url
          parse_callback
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use constant SEP => ":";
use constant FLOW_TYPE => "web_server";

sub get_authorization_message {
    my ( $req_info, $session, $args, $namespace, $endpoints, $scope ) = @_;
    my $rid = $req_info->{'rid'};
    my ($uauth_url) =
      get_userauth_url( $req_info, $session, $args, $namespace, $endpoints,
                        $scope );
    return $uauth_url;
}

sub get_userauth_url {
    my ( $req_info, $session, $args, $namespace, $endpoints, $scope ) = @_;
    my $logger      = get_logger();
    my $rid         = $req_info->{'rid'};
    my $request_url = $endpoints->{'authorization_url'};
    my $consumer_tokens =
      get_consumer_tokens( $req_info, $session, $namespace );
    my $request_tokens =
      get_request_tokens( $req_info, $session, $args, $namespace, $endpoints,
                          $scope );
    store_token( $rid, $session, 'request_token', $request_tokens->{'token'},
                 $namespace, $scope );
    store_token( $rid, $session, 'request_token_secret',
                 $request_tokens->{'secret'},
                 $namespace, $scope );
    my $auth_url =
        $request_url
      . '?oauth_token='
      . $request_tokens->{'token'}
      . '&hd=default';
    $logger->debug( "userauth url: ", $auth_url );

    return $auth_url;
}

sub get_access_tokens {
    my $req_info = shift;
    my $session = shift;
    my $namespace = shift;
    if ($namespace eq 'facebook') {
        my ($endpoint,$callback_hash) = @_;
        return get_access_tokens_v2($req_info,$session,$namespace,$endpoint,$callback_hash);
    } else {
        my ($endpoints,$scope) = @_;
        return get_access_tokens_v1($req_info,$session,$namespace,$endpoints,$scope);
    }

}

sub get_access_tokens_v2 {
    my ($req_info,$session,$namespace,$endpoint,$callback_hash) = @_;
    my $logger = get_logger();
    $logger->trace("Session: ", sub {Dumper($session)});
    my $rid         = $req_info->{'rid'};
    my $verifier = uri_escape(get_token( $rid, $session, 'oauth_verifier', $namespace));
    my $callback = uri_escape(make_callback_url($req_info,$namespace));
    my $access_url = $endpoint->{'access_token_url'} || '';
    my $consumer_tokens = get_consumer_tokens($req_info,$session,$namespace);
    my $content;
    $content .= 'client_id=' . $consumer_tokens->{"consumer_key"};
    $content .= '&type='.FLOW_TYPE;
    $content .= '&code=' . $verifier;
    $content .= '&client_secret=' . $consumer_tokens->{"consumer_secret"};
    $content .= '&redirect_uri=' . $callback;
    my $mixed = $access_url . '?' . $content;
    $logger->debug("Access Url: ", $mixed);
    my $hreq = HTTP::Request->new( GET => $mixed);
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->simple_request($hreq);
    if ($resp->is_success) {
        my $content = $resp->content();
        my @elements = split(/&/,$content);
        my $token_hash;
        foreach my $element (@elements) {
            my ($key,$value) = split(/=/,$element);
            if ($key eq 'access_token') {
                store_token( $rid, $session, 'access_token', $value, $namespace);
            }
        }
    }
    $logger->trace("Request: ", sub {Dumper($hreq)});
    $logger->trace("Response: ", sub {Dumper($resp->content_ref())});
    return $resp;
}

sub get_access_tokens_v1 {
    my ( $req_info, $session, $namespace, $endpoints, $scope ) = @_;
    my $logger = get_logger();
    $logger->trace("Get Access Tokens v1");
    $logger->trace( "Endpoints: ", sub { Dumper($endpoints) } );
    my $rid         = $req_info->{'rid'};
    my $request_url = $endpoints->{'access_token_url'};
    my $consumer_tokens =
      get_consumer_tokens( $req_info, $session, $namespace );
    my $oauth_token =
      get_token( $rid, $session, 'oauth_token', $namespace, $scope );
    my $token_secret =
      get_token( $rid, $session, 'request_token_secret', $namespace, $scope );
    my $verifier =
      get_token( $rid, $session, 'oauth_verifier', $namespace, $scope );
    my $request = Net::OAuth->request("access token")->new(
                     'consumer_key'    => $consumer_tokens->{'consumer_key'},
                     'consumer_secret' => $consumer_tokens->{'consumer_secret'},
                     'token'           => $oauth_token,
                     'token_secret'    => $token_secret,
                     'verifier'        => $verifier,
                     'request_url'     => $request_url,
                     'request_method'  => 'GET',
                     'signature_method' => 'HMAC-SHA1',
                     'timestamp'        => time(),
                     'nonce'            => nonce(),
    );
    $request->sign();

    my $surl = $request->to_url();
    $logger->debug( "Access URL: ", $surl );
    my $ua   = LWP::UserAgent->new();
    my $resp = $ua->request( GET $surl);

    if ( $resp->is_success() ) {
        my $oresp =
          Net::OAuth->response('access token')
          ->from_post_body( $resp->content );
        my $oauth_token        = $oresp->token;
        my $oauth_token_secret = $oresp->token_secret;
        store_token( $rid, $session, 'access_token', $oauth_token, $namespace,
                     $scope );
        store_token( $rid, $session, 'access_token_secret', $oauth_token_secret,
                     $namespace, $scope );
    } else {
        $logger->warn(
"Access token request failed in context ($namespace) from $request_url" );
    }
    return;

}

sub get_request_tokens {
    my ( $req_info, $session, $args, $namespace, $endpoints, $scope ) = @_;
    my $logger      = get_logger();
    my $rid         = $req_info->{'rid'};
    my $request_url = $endpoints->{'request_token_url'};
    $logger->debug( "request url: ", $request_url );
    my $consumer_tokens =
      get_consumer_tokens( $req_info, $session, $namespace );
    $logger->trace( "Consumer tokens: ", sub { Dumper($consumer_tokens) } );
    my $callback = make_callback_url( $req_info, $namespace );
    $logger->trace("REQUEST Callback: $callback");
    my $request = Net::OAuth->request("request token")->new(
                     'consumer_key'    => $consumer_tokens->{'consumer_key'},
                     'consumer_secret' => $consumer_tokens->{'consumer_secret'},
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

    if ( $resp->is_success() ) {
        my $oresp =
          Net::OAuth->response('request token')
          ->from_post_body( $resp->content );
        my $oauth_token        = $oresp->token;
        my $oauth_token_secret = $oresp->token_secret;
        $logger->debug("rt: $oauth_token rts: $oauth_token_secret");
        return { 'token' => $oauth_token, 'secret' => $oauth_token_secret };
    } else {
        $logger->warn(
              "Token request failed in context ($namespace) from $request_url");
    }

    return undef;

}

sub get_protected_resource {
    my ( $req_info, $session, $namespace, $url, $scopche) = @_;
    my $logger = get_logger();
    if ($namespace eq 'facebook') {
        return get_protected_resource_v2($req_info, $session, $namespace, $url,$scopche);
    } else {
        return get_protected_resource_v1( $req_info, $session, $namespace, $url, $scopche );
    }

}

sub get_protected_resource_v2 {
    my ( $req_info, $session, $namespace, $url,$cache) = @_;
    my $logger = get_logger();
    $logger->debug("Protected Request URL: ",$url);
    my $rid    = $req_info->{'rid'};
    if ($cache) {
        my $key = $rid.":".$url;
        $logger->debug("Check cache for $key");
        my $content = check_cache($key);
        if ($content) {
            $logger->debug("Cache hit");
            my $r = HTTP::Response->new(HTTP_NON_AUTHORITATIVE_INFORMATION);
            $r->content($content);
            return $r;
        }

    }
    my $access_token = get_token( $rid, $session, 'access_token', $namespace);
    my ($urlpart,$querypart) = split(/\?/,$url);
    my @parts;
    if ($querypart) {
        @parts = split(/&/,$querypart);
    }
    push(@parts,"access_token=$access_token");
    $querypart = join("&",@parts);
    my $token_url = "$urlpart?$querypart";
    $logger->trace("Protected Request URL: ",$token_url);
    my $hreq = HTTP::Request->new( GET => $token_url );
    my $ua   = LWP::UserAgent->new;
    my $resp = $ua->simple_request($hreq);
    return $resp;
}

sub get_protected_resource_v1 {
    my ( $req_info, $session, $namespace, $url, $scope ) = @_;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    my $consumer_tokens =
      get_consumer_tokens( $req_info, $session, $namespace );
    my $token = get_token( $rid, $session, 'access_token', $namespace, $scope );
    my $token_secret =
      get_token( $rid, $session, 'access_token_secret', $namespace, $scope );
    my $request =
      Net::OAuth::ProtectedResourceRequest->new(
                     'consumer_key'    => $consumer_tokens->{'consumer_key'},
                     'consumer_secret' => $consumer_tokens->{'consumer_secret'},
                     'token'           => $token,
                     'token_secret'    => $token_secret,
                     'request_url'     => $url,
                     'request_method'  => 'GET',
                     'signature_method' => 'HMAC-SHA1',
                     'timestamp'        => time(),
                     'nonce'            => nonce(),
      );

    $request->sign();

    my $hreq = HTTP::Request->new( GET => $url );
    $hreq->header( 'Authorization' => $request->to_authorization_header );
    if ( $namespace eq 'google' ) {
        $hreq->header( 'Content-type'  => 'application/atom+xml' );
        $hreq->header( 'GData-Version' => "2.0" );
    }
    my $ua   = LWP::UserAgent->new;
    my $resp = $ua->simple_request($hreq);

    my $count = 1;
    while ( $resp->is_redirect ) {
        $logger->trace( "Redirect ($count): ", $resp->header("location") );
        my $r_url = URI->new( $resp->header("location") );
        $hreq->uri($r_url);
        my %query = $r_url->query_form;
        foreach my $param ( keys %query ) {
            $request->{'extra_params'}->{$param} = $query{$param};
        }
        $r_url->query(undef);
        $request->{'request_url'} = $r_url;
        $request->sign();
        $hreq->header( 'Authorization' => $request->to_authorization_header );
        $resp = $ua->simple_request($hreq);
    }
    return $resp;

}

sub post_protected_resource {
    my ( $req_info, $session, $namespace, $scope, $url, $content ) = @_;
    my $logger = get_logger();
    if ($namespace eq 'facebook') {
        return post_protected_resource_v2($req_info, $session, $namespace, $url, $content);
    } else {
        return post_protected_resource_v1($req_info, $session, $namespace, $scope, $url, $content);
    }
}

sub post_protected_resource_v2 {
    my ( $req_info, $session, $namespace, $url, $content ) = @_;
    my $logger = get_logger();
    $logger->debug("URL: ", $url);
    my $rid    = $req_info->{'rid'};
    my $access_token = get_token( $rid, $session, 'access_token', $namespace);
    my $hreq = HTTP::Request->new(POST => $url);
    if ($content) {
        $content .= "&access_token=$access_token";
    } else {
        $content = "access_token=$access_token";
    }
    $hreq->content($content);
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->simple_request($hreq);
    return $resp;
}

sub post_protected_resource_v1 {
    my ( $req_info, $session, $namespace, $scope, $url, $content ) = @_;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    my $consumer_tokens =
      get_consumer_tokens( $req_info, $session, $namespace );
    my $token = get_token( $rid, $session, 'access_token', $namespace, $scope );
    my $token_secret =
      get_token( $rid, $session, 'access_token_secret', $namespace, $scope );
    my $request =
      Net::OAuth::ProtectedResourceRequest->new(
                     'consumer_key'    => $consumer_tokens->{'consumer_key'},
                     'consumer_secret' => $consumer_tokens->{'consumer_secret'},
                     'token'           => $token,
                     'token_secret'    => $token_secret,
                     'request_url'     => $url,
                     'request_method'  => 'POST',
                     'signature_method' => 'HMAC-SHA1',
                     'timestamp'        => time(),
                     'nonce'            => nonce(),
      );

    $request->sign();

    my $hreq = HTTP::Request->new( POST => $url );
    $hreq->content($content);
    $hreq->header( 'Authorization' => $request->to_authorization_header );
    if ( $namespace eq 'google' ) {
        $hreq->header( 'Content-type'  => 'application/atom+xml' );
        $hreq->header( 'GData-Version' => "2.0" );
    }
    my $ua   = LWP::UserAgent->new;
    my $resp = $ua->simple_request($hreq);

    my $count = 1;
    while ( $resp->is_redirect ) {
        $logger->debug( "Redirect ($count): ", $resp->header("location") );
        my $r_url = URI->new( $resp->header("location") );
        $hreq->uri($r_url);
        my %query = $r_url->query_form;
        foreach my $param ( keys %query ) {
            $request->{'extra_params'}->{$param} = $query{$param};
        }
        $r_url->query(undef);
        $request->{'request_url'} = $r_url;
        $request->sign();
        $hreq->header( 'Authorization' => $request->to_authorization_header );
        $resp = $ua->simple_request($hreq);
    }
    return $resp;

}

sub set_auth_tokens {
    my ( $r, $method, $rid, $session,$namespace ) = @_;
    my $logger = get_logger();
    $logger->trace("Set auth token session: ", sub { Dumper($session)});
    if ($namespace eq 'facebook') {
        return set_auth_tokens_v2($r, $method, $rid, $session, $namespace);
    } else {
        return set_auth_tokens_v1($r, $method, $rid, $session);
    }
}

sub set_auth_tokens_v2 {
    my ( $r, $method, $rid, $session, $namespace) = @_;
    my $logger = get_logger();
    my $req       = Apache2::Request->new($r);
    my $verifier  = $req->param('code');
    $logger->trace(
            "User returned from $namespace with verifier => $verifier" );
    $logger->trace("Auth token request returned: ", sub { Dumper($req)});
    store_token( $rid, $session, 'oauth_verifier', $verifier, $namespace);


}

sub set_auth_tokens_v1 {
    my ( $r, $method, $rid, $session ) = @_;
    my $logger = get_logger();
    $logger->trace( "Session: ", Dumper [$session] );
    my $req       = Apache2::Request->new($r);
    my $token     = $req->param('oauth_token');
    my $verifier  = $req->param('oauth_verifier');
    my $caller    = $req->param('caller');
    my $scope     = get_scope_from_token( $rid, $session, $token );
    my $namespace = get_namespace_from_token( $rid, $session, $token );
    $logger->debug(
            "User returned from $namespace ($scope) with oauth_token => $token",
            " &  oauth_verifier => $verifier & caller => $caller" );
    $logger->trace( "Session token scope: ", sub { Dumper($scope) } );
    store_token( $rid, $session, 'oauth_token', $token, $namespace, $scope );
    store_token( $rid, $session, 'oauth_verifier', $verifier, $namespace,
                 $scope );
    return $scope;
}

sub store_token {
    my ( $rid, $session, $name, $value, $namespace, $scope ) = @_;
    my $logger = get_logger();
    my $lscope;
    if ( ref $scope eq 'HASH' ) {
        $lscope = $scope->{'dname'};
    } else {
        $lscope = $scope;
    }

    my $key = '';
    if ( defined $lscope ) {
        $key = $namespace . SEP . $lscope;
    } else {
        $key = $namespace;
    }
    $key .= SEP . $name;
    session_store( $rid, $session, $key, $value );
    $logger->trace("Stored token ($name): ", sub { Dumper($session)});
}

sub get_token {
    my ( $rid, $session, $name, $namespace, $scope ) = @_;
    my $logger = get_logger();
    my $key = '';
    my $lscope;
    if ( ref $scope eq 'HASH' ) {
        $lscope = $scope->{'dname'};
    } else {
        $lscope = $scope;
    }
    if ( defined $lscope ) {
        $key = $namespace . SEP . $lscope;
    } else {
        $key = $namespace;
    }
    $logger->debug("Get token ($key)");
    $key .= SEP . $name;
    return session_get( $rid, $session, $key );
}

sub trim_tokens {
    my ( $rid, $session, $namespace, $scope ) = @_;
    my $logger = get_logger();
    my $key    = '';
    my $lscope;
    if ( ref $scope eq 'HASH' ) {
        $lscope = $scope->{'dname'};
    } else {
        $lscope = $scope;
    }
    if ( defined $lscope ) {
        $key = $namespace . SEP . $lscope . SEP . 'access';
    }
    foreach my $session_key ( @{ session_keys( $rid, $session ) } ) {

        my $re = qr/^$key/;
        if ( !( $session_key =~ $re ) ) {
            session_delete( $rid, $session, $session_key );
        }
    }

}

sub blast_tokens {
    my ( $rid, $session, $namespace, $scope ) = @_;
    my $logger = get_logger();
    my $key    = '';
    my $lscope;
    if ( ref $scope eq 'HASH' ) {
        $lscope = $scope->{'dname'};
    } else {
        $lscope = $scope;
    }
    if ( defined $lscope ) {
        $key = $namespace . SEP . $lscope;
    }
    foreach
      my $session_key ( @{ Kynetx::Session::session_keys( $rid, $session ) } )
    {
        my $re = qr/^$key/;
        if ( $session_key =~ $re ) {
            session_delete( $rid, $session, $session_key );
        }
    }

}

sub get_namespace_from_token {
    my ( $rid, $session, $token ) = @_;
    my $logger = get_logger();
    my $keys = session_keys( $rid, $session );
    foreach my $key (@$keys) {
        my ( $namespace, $scope, $var ) = parse_oauth_session_key($key);
        my $val = session_get( $rid, $session, $key );
        if ( $val eq $token ) {
            return $namespace;
        }
    }
    return undef;
}

sub get_scope_from_token {
    my ( $rid, $session, $token ) = @_;
    my $logger = get_logger();
    my $keys = session_keys( $rid, $session );
    foreach my $key (@$keys) {
        my ( $namespace, $scope, $var ) = parse_oauth_session_key($key);
        my $val = session_get( $rid, $session, $key );
        if ( $val eq $token ) {
            return $scope;
        }
    }
    return undef;
}

sub get_tokens_by_oauth_token {
    my ( $rid, $session, $token ) = @_;
    my $logger     = get_logger();
    my $token_hash = undef;
    my $token_ptr  = undef;
    my $keys       = session_keys( $rid, $session );
    foreach my $key (@$keys) {
        my ( $namespace, $scope, $var ) = parse_oauth_session_key($key);
        my $val = session_get( $rid, $session, $key );
        $token_hash->{$namespace}->{$scope}->{$var} = $val;
        if ( $val eq $token ) {
            $token_ptr = $token_hash->{$namespace}->{$scope};
        }
    }
    return $token_ptr;
}

sub parse_oauth_session_key {
    my ($key) = @_;
    my $logger = get_logger();
    my ( $namespace, $scope, $var );
    my @parts = split( SEP, $key );
    if ( int(@parts) == 3 ) {
        return ( $parts[0], $parts[1], $parts[2] );
    } elsif ( int(@parts) == 2 ) {
        return ( $parts[0], 'default', $parts[1] );
    } else {
        return undef;
    }

}

sub nonce {
    my @a = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
    my $nonce = '';
    for ( 0 .. 31 ) {
        $nonce .= $a[ rand( scalar(@a) ) ];
    }

    return $nonce;
}

sub get_consumer_tokens {
    my ( $req_info, $session, $namespace ) = @_;
    my $logger = get_logger();
    my $consumer_tokens;
    my $rid    = $req_info->{'rid'};
    unless ( $consumer_tokens = $req_info->{ $rid . ':key:' . $namespace } ) {
        my $ruleset =
          Kynetx::Repository::get_rules_from_repository( $rid, $req_info );
        $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{$namespace};
    }
    $logger->trace("consumer tokens",sub {Dumper($consumer_tokens)});
    return $consumer_tokens;
}

sub parse_callback {
    my ($r,$method,$rid,$namespace) = @_;
    my $logger = get_logger();
    my $cb_obj;
    $cb_obj->{'namespace'} = $namespace;
    my $req       = Apache2::Request->new($r);
    $cb_obj->{'req_info'}  = Kynetx::Request::build_request_env( $r, $method, $rid );
    my $uri = $cb_obj->{'req_info'}->{'uri'};
    my $rest_part =
          Kynetx::Configure::get_oauth_param( $namespace, 'callback' );
    if ($namespace eq 'facebook') {
        if ($uri =~ m/$rest_part/) {
            if ($uri =~ m/$rest_part\/(\w+)\/(\w+)\/(\S+)\/?/) {
                $cb_obj->{'rid'} = $1;
                $cb_obj->{'req_info'}->{'rule_version'} = $2;
                $cb_obj->{'caller'} = $3;
            }
        } else {
            $logger->warn("Error parsing facebook callback: ",$uri);
        }
    } else {
        $cb_obj->{'namespace'} = 'common';
        $cb_obj->{'caller'}    = $req->param('caller');
        $cb_obj->{'verifier'}  = uri_escape($req->param('code'));
        $cb_obj->{'version'}   = $cb_obj->{'req_info'}->{'rule_version'} || 'prod';
    }
    return $cb_obj;
}

sub make_callback_url {
    my ( $req_info, $namespace ) = @_;
    my $logger = get_logger();

    if ( $namespace eq 'facebook' ) {
        return _make_facebook_callback_url($req_info);
    } else {
        my $rid     = $req_info->{'rid'};
        my $version = $req_info->{'rule_version'} || 'prod';
        my $caller  = $req_info->{'caller'};
        my $host    = Kynetx::Configure::get_config('EVAL_HOST');
        my $port    = Kynetx::Configure::get_config('OAUTH_CALLBACK_PORT');
        my $rest_part =
          Kynetx::Configure::get_oauth_param( $namespace, 'callback' );
        my $url_part = "/ruleset/$rest_part/";
        my $base     = "http://" . $host . ":" . $port . $url_part . $rid . "?";
        my $callback =
          Kynetx::Util::mk_url(
                                $base,
                                {
                                   'caller',                  $caller,
                                   "$rid:kynetx_app_version", $version
                                }
          );
        $logger->debug( "OAuth callback url: ", $callback );
        #return uri_escape($callback);
        return $callback;
    }
}

sub _make_facebook_callback_url {
    my ($req_info) = @_;
    my $logger     = get_logger();
    my $rid        = $req_info->{'rid'};
    my $version = $req_info->{'rule_version'} || 'prod';
    my $caller  = $req_info->{'caller'};
    my $host    = Kynetx::Configure::get_config('EVAL_HOST');
    my $port    = Kynetx::Configure::get_config('OAUTH_CALLBACK_PORT');
    my $rest_part =
      Kynetx::Configure::get_oauth_param( 'facebook', 'callback' );
    my $base = "http://$host:$port/ruleset/$rest_part/$rid/$version/$caller";
    $logger->trace( "OAuth callback url: ", $base );
    return $base;

}

1;
