package Kynetx::OAuth::ProtectedResourceRequest;

# file: Kynetx/OAuth/OAccess.pm
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

use Kynetx::Util;
use Kynetx::Persistence::KEN qw(
  ken_lookup_by_username
);
use Kynetx::Modules::PCI qw(
  auth_ken
);
use Kynetx::OAuth::OAuth20;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Apache2::Const qw(:common M_GET M_POST :http);
use Apache2::Access ();

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
  Log::Log4perl::MDC->put('rule', '[PRR]');
  
  my $logger = get_logger('Kynetx');
  # get the client-supplied credentials
  $logger->debug("Protected Resource Request");
  my $error;
  my $error_code;
  
  my ($status, $password) = $r->get_basic_auth_pw;
  my $headers_in = $r->headers_in();
  my $auth = $headers_in->{'Authorization'};
  my ($method,$token) = split(/ /,$auth);
  if ($method eq 'Bearer') {
    $logger->debug("Bearer token");
  } elsif ($r->method_number == Apache2::Const::M_GET) {
    $logger->debug("Request is POST");
    my $args = $r->args;
    $token = Kynetx::OAuth::OAuth20::query_param($r->args,'access_token');
  } elsif ($r->method_number == Apache2::Const::M_POST) {
    $logger->debug("Request is POST");
    $token = Kynetx::OAuth::OAuth20::post_param($r,'access_token');    
  } else {
    $r->err_headers_out->set('WWW-Authenticate' => 'Bearer realm="Kynetx"');
    $r->err_headers_out->add('WWW-Authenticate' => 'error="invalid_request"');
    return Apache2::Const::HTTP_BAD_REQUEST; 
  }
  if ($token) {
    if (check_expiration($token)) {
      my $eci = Kynetx::Persistence::KToken::get_token_by_token_name($token);
      if ($eci) {
        $r->user($eci);
        return Apache2::Const::OK;
      }  else {
        $error->{'error'} = 'invalid_token';
        $error->{'error_description'} = 'Access token is invalid';
        $error_code =  Apache2::Const::HTTP_UNAUTHORIZED;       
      }  
    } else {
        $error->{'error'} = 'invalid_token';
        $error->{'error_description'} = 'Access token is expired';
        $error_code =  Apache2::Const::HTTP_UNAUTHORIZED;             
    }       
  } else {
    $error->{'error'} = 'invalid_request';
    $error->{'error_description'} = 'Missing required parameter: access_token';
    $error_code =  Apache2::Const::HTTP_BAD_REQUEST;             
  }
        
  $r->err_headers_out->set('WWW-Authenticate' => 'Bearer realm="Kynetx"');
  foreach my $err (keys %{$error}) {
    $r->err_headers_out->add('WWW-Authenticate' => "$err=\"$error->{$err}\"");
  }
  return $error_code;   
}


sub check_expiration {
  my ($token) = @_;
  my ($atoken,$create)= split(/\|/,$token);
  my $logger=get_logger();
  $logger->debug("Created: $create");
  my $time = MIME::Base64::decode_base64url($create);
  $logger->debug("Time: $time");
  return 1;
}


sub set_user_from_post {
  my ($r) = @_;
  my $logger= get_logger();
  my $req = Apache2::Request->new($r);
  my $user = $req->param('client_id');
  $logger->debug("Get user from client id: ",$user); 
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($user);
  if (defined $ken) {
    $r->user($user);
    return Apache2::Const::OK;
  } else {
    return Apache2::Const::FORBIDDEN; 
  }
}

sub set_auth_type {
  my ($r,$eci,$token) = @_;
  $r->ap_auth_type('Basic');
  $r->auth_name('Kynetx');
  $r->user($eci);
}


1;
