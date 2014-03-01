package Kynetx::OAuth::OAuthorize;

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
  Log::Log4perl::MDC->put('rule', '[OAuthorize]');
  
  my $logger = get_logger('Kynetx');
  # get the client-supplied credentials
  $logger->debug("Authorize handler");
  my ($redirect_uri,$client_id,$response_type,
      $state,$params,$uri_match,$rparams,$plain_redirect);
  
  if ($r->method_number == Apache2::Const::M_GET) {
    my $args = $r->args();
    $logger->debug("Request method is GET");
    my @pairs = split(/\&/,$args);
    $params = Kynetx::Util::from_pairs(\@pairs);
  }elsif ($r->method_number==Apache2::Const::M_POST) {
    $logger->debug("Request method is POST");
    
    return OK;
  } else {
    $r->allowed($r->allowed | (1 << Apache2::Const::M_GET) | (1 << Apache2::Const::M_POST));
    return Apache2::Const::DECLINED;    
  }
  
  $redirect_uri = $params->{'redirect_uri'};
  $logger->debug("URI: $redirect_uri");
  $client_id = $params->{'client_id'};
  $logger->debug("ECI: $client_id");
  $response_type = $params->{'response_type'};
  $logger->debug("rt: $response_type");
  $state = $params->{'state'};
  $logger->debug("State: $state");
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($client_id);
  if ($ken) {
    $logger->debug("KEN: $ken");
    if ($redirect_uri) {
      $plain_redirect = uri_unescape($redirect_uri);
      my $list = Kynetx::Persistence::KPDS::get_callbacks($ken,$client_id);
      foreach my $cb_uri (uri_unescape(@{$list})) {
        $logger->debug("Stored callback: $cb_uri");
        if ($cb_uri eq $plain_redirect) {
          $uri_match = 'exact';
          last;
        } elsif ($plain_redirect =~ m/^$cb_uri/){
          $uri_match = 'match';
          last;
        }
      }
      $logger->debug("Uri match: $uri_match");
      return Apache2::Const::HTTP_BAD_REQUEST unless $uri_match;
    }
    my $oauth_handler = Kynetx::Configure::get_config("oauth_server")->{"auth_ruleset"};
    $rparams->{'kvars'} = '{}';
    $rparams->{'uri_redirect'} = $plain_redirect;
    $rparams->{'developer_eci'} = $client_id;
    if ($state) {
      $rparams->{'client_state'} = $state;
    }
    
    my $ruleset_redirect = Kynetx::Util::mk_url($oauth_handler . _eid(),$rparams);
    $logger->debug("Auth rule: $ruleset_redirect");
    $r->headers_out->set(Location => $ruleset_redirect);
		return Apache2::Const::HTTP_MOVED_TEMPORARILY;          
  } else {
    $logger->debug("Client ID invalid: $client_id");
    return Apache2::Const::HTTP_BAD_REQUEST;
  }
  
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
