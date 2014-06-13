package Kynetx::OAuth::RequestToken;

# file: Kynetx/OAuth/Authorize.pm
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
use lib qw(/web/lib/perl);
use utf8;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use HTML::Template;
use JSON::XS;
use Cache::Memcached;
use DateTime::Format::ISO8601;
use Benchmark ':hireswallclock';
use Encode qw(from_to);
use URI::Escape qw(
  uri_unescape
  uri_escape_utf8
);

use Kynetx::Util;
use Kynetx::Persistence::KEN qw(
  ken_lookup_by_username
);
use Kynetx::Persistence::KPDS qw(
  get_callbacks
);
use Kynetx::Modules::PCI qw(
  auth_ken
);
use Kynetx::OAuth::OAuth20;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Apache2::Const qw(:common :http M_GET M_POST);

no warnings 'redefine';

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );


sub handler {
  my $r = shift;
  Kynetx::Memcached->init();
  Kynetx::Util::config_logging($r);
  Log::Log4perl::MDC->put('site', 'OAuth2.0');
  Log::Log4perl::MDC->put('rule', '[RequestToken]');
  Log::Log4perl::MDC->put( 'eid', undef );    # no eid
  
  my $logger = get_logger();
  my $error;
  my $error_code;
  
  $logger->debug("RequestToken");  
  if ($r->method_number == Apache2::Const::M_GET) {
    $logger->debug("Method GET");
    my $qstring = $r->args;
    my $client_id = Kynetx::OAuth::OAuth20::query_param($qstring,'client_id');
    $logger->debug("Client ID: $client_id");
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($client_id);
    $logger->trace("KEN: $ken");
    if ($ken) {
      $r->notes->set('client_id',$client_id);
      $r->push_handlers(PerlAccessHandler => \&sort_response_type);
      return Apache2::Const::OK;
    } else {
      $error = {
        'error' => 'access_denied',
        'error_description' => 'Invalid client_id'
      };
      $error_code = Apache2::Const::FORBIDDEN;
    }
  } else {
    $r->allowed($r->allowed | (1 << Apache2::Const::M_GET));
    return Apache2::Const::HTTP_METHOD_NOT_ALLOWED;    
  } 
    $r->err_headers_out->set('WWW-Authenticate' => 'Basic realm="Kynetx"');
    if (defined $error) {
      foreach my $err (keys %{$error}) {
        $r->err_headers_out->add('WWW-Authenticate' => "$err=\"$error->{$err}\"");
      }
    }
    return $error_code || Apache2::Const::FORBIDDEN;
}

sub sort_response_type {
  my $r = shift;
  my $logger = get_logger();
  my $error;
  my $error_code;
  $logger->debug("Choose Response Path");
  my $client_id = $r->notes->get('client_id');
  $logger->debug("Client ID: $client_id");
  my $args = $r->args();
  my $qstring = $r->args;
  my $response_type = Kynetx::OAuth::OAuth20::query_param($qstring,'response_type');
  my $redirect_uri =Kynetx::OAuth::OAuth20::query_param($qstring,'redirect_uri');
  my ($valid_redirect,$r_type) = validate_redirect($client_id,$redirect_uri);
  if (defined $valid_redirect) {
    $r->notes->set('redirect_uri',$redirect_uri);
    $logger->debug("Response Type: $response_type");    
    if ($response_type eq 'code') {
      $r->push_handlers(PerlAccessHandler => \&code_request);
      return Apache2::Const::OK;
    } elsif ($response_type eq 'token') {
      
    } else {
      $error = {
        'error' => 'unsupported_response_type',
        'error_description' => "Unknown response type: $response_type"
      };
      return error_redirect($r,$redirect_uri,$error);
    }
    return Apache2::Const::OK;    
  } else {
    my $description = $r_type;
    $r->err_headers_out->set('WWW-Authenticate' => 'Basic realm="Kynetx"');
    $r->err_headers_out->add('WWW-Authenticate' => "error=\"unauthorized_client\"");
    $r->err_headers_out->add('WWW-Authenticate' => "error_description=\"$description\"");
    return Apache2::Const::HTTP_BAD_REQUEST;
  }
}

sub code_request {
  my $r = shift;
  my $logger = get_logger();
  my $error;
  my $error_code;
  $logger->debug("Make redirect for Authorization Request");
  my $client_id = $r->notes->get('client_id');
  my $redirect = $r->notes->get('redirect_uri');
  my $qstring = $r->args;
  my $state = Kynetx::OAuth::OAuth20::query_param($qstring,'state');
  
  my $rparams;
  my $oauth_handler = Kynetx::Configure::get_config("oauth_server")->{"auth_ruleset"};
  $oauth_handler =~ s!/*$!/!; # Add a trailing slash  
  $rparams->{'kvars'} = '{}';
  $rparams->{'uri_redirect'} = uri_unescape($redirect);
  $rparams->{'developer_eci'} = $client_id;
  if ($state) {
    $rparams->{'client_state'} = $state;
  }  
  my ($method,$path) = $r->path_info() =~ m!/([a-z+_]+)/*(.*)!;
  
  my $path_part;
  
  # Determine whether this is a pure OAuth or a OAuth invitation
  if (defined $path && $path eq "newuser") {
    $path_part = $path;
  } else {
    $path_part = _eid();
  }
  
  my $ruleset_redirect = Kynetx::Util::mk_url($oauth_handler . $path_part ,$rparams);
  $logger->debug("Auth rule: $ruleset_redirect");
  $r->headers_out->set(Location => $ruleset_redirect);
	return Apache2::Const::HTTP_MOVED_TEMPORARILY;          
}

sub validate_redirect {
  my ($client_id,$uri) = @_;
  my $logger = get_logger();
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($client_id);
  my $list = Kynetx::Persistence::KPDS::get_callbacks($ken,$client_id);
  if (defined $uri) {
    $logger->debug("Match redirect");
    my $uri_match;
    my $plain = uri_unescape($uri);
    foreach my $cb_uri (@{$list}) {
      if ($cb_uri eq $plain) {
        $uri_match = 'exact';
        last;
      } elsif ($plain =~ m/^$cb_uri/){
        $uri_match = 'match';
        last;
      }
    }
    if ($uri_match){
      return ($uri,$uri_match);
    } else {
      return (undef,"Redirect $plain not configured");
    }
  } else {
    $logger->debug("Get default redirect");    
    if (scalar @{$list} != 1) {
      return (undef,"Unable to determine default redirect");
    } else {
      return ($list->[0],'default');
    }
  }
}

sub error_redirect {
  my ($r,$redirect_uri,$error) = @_;
  my $logger = get_logger();
  my $url = Kynetx::Util::mk_url($redirect_uri,$error);
  $logger->debug("Error url: $url");
  $r->headers_out->set(Location => $url);
	return Apache2::Const::HTTP_MOVED_TEMPORARILY;          
}

sub custom_error {
  my ($r,$hcode,$code,$description) = @_;
  $r->content_type('application/json;charset=UTF-8');
  $r->headers_out->set('Cache-Control' => 'no-store');
  $r->headers_out->set('Pragma' => 'no-cache');
  $r->status($hcode);
  $r->custom_response($hcode, "{\n \"error\":\"$code\",\n \"error_description\":\"$description\"\n}");
  return $hcode;
}

sub auth_user {
  my ($r) = @_;
    
}

sub _eid {
  my @chars = ("A".."Z","a".."z",0..9,"_");
  my $string;
  $string .= $chars[rand @chars] for 0..9;
  return $string;
}

1;
