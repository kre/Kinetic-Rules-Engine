package Kynetx::Repository;

# file: Kynetx/Repository.pm
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
use APR::URI;
use Encode;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
$Data::Dumper::Indent = 1;
use Digest::MD5 qw(md5_base64);

use Kynetx::Memcached qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Predicates::Page;
use Kynetx::Rules;
use Kynetx::Rids qw(:all);
use Kynetx::Persistence::Ruleset qw(:all);
use Kynetx::Repository::HTTP;
use Kynetx::Repository::File;
use Kynetx::Repository::XDI;
use Kynetx::Persistence::Ruleset;

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

# $sversion allows modules to specify the version of the ruleset that is requested
# $text requests the krl not the ast
sub get_rules_from_repository {

  my ( $rid_info, $req_info, $sversion, $localparsing, $text ) = @_;

  my $logger = get_logger();

  my $rid = Kynetx::Rids::get_rid($rid_info);

  # default to production for svn repo
  # defaults to production when no version specified
  # use specified version first
  my $version =
       $sversion
    || Kynetx::Rids::get_version($rid_info)
    || Kynetx::Predicates::Page::get_pageinfo( $req_info, 'param',
    ['kynetx_app_version'] )
    || Kynetx::Predicates::Page::get_pageinfo( $req_info, 'param',
    ['kinetic_app_version'] )
    || 'prod';
  $req_info->{'rule_version'} = $version;

  my $memd = Kynetx::Memcached::get_memd();

  my $rs_key = make_ruleset_key( $rid, $version );

  # wait if this ruleset's being parsed now
  my $counter = 0;
  while (
    Kynetx::Memcached::is_parsing( $memd, $rs_key )
    && $counter < 6    # don't wait forever
    )
  {
    sleep 1;
    $counter++;
  }

  my $ruleset = $memd->get($rs_key);

  # check cache for ruleset
  if ( $ruleset
    && $ruleset->{'optimization_version'}
    && $ruleset->{'optimization_version'} ==
    Kynetx::Rules::get_optimization_version()
    && !$text )
  {
    $logger->debug(
"Using cached ruleset for $rid ($version) with key $rs_key & optimization version ",
      $ruleset->{'optimization_version'}
    );

    return $ruleset;
  }


  # this gets cleared when we're done
  $logger->debug("Setting parsing semaphore for $rs_key");
  Kynetx::Memcached::set_parsing_flag( $memd, $rs_key );
  
  $ruleset = get_ruleset_krl($rid_info,$version);
  
  Kynetx::Memcached::clr_parsing_flag($memd,$rs_key);
  
  if (defined $ruleset) {
    $req_info->{'rule_version'} = $version;
    $ruleset = Kynetx::Parser::parse_ruleset($ruleset);
    unless($ruleset->{'ruleset_name'} eq 'norulesetbythatappid' || 
      defined $ruleset->{'error'}) {
        $ruleset = Kynetx::Rules::optimize_ruleset($ruleset);
        $logger->debug("Found rules  for $rid");
        $logger->debug("Caching ruleset for $rid using key $rs_key");
        $memd->set($rs_key,$ruleset);
      } else {
        if ($ruleset->{'ruleset_name'} eq 'norulesetbythatappid') {
          $logger->error("Ruleset $rid not found");
      } elsif (defined $ruleset->{'error'}) {
          $logger->error("Ruleset parsing error for $rid: ");
      } else {
          $logger->error("Unspecified ruleset repository error for $rid");
      }
      }
    return $ruleset;
  } else {
    $logger->warn("Failed to recover ruleset for $rid, creating empty ruleset");
    return make_empty_ruleset($rid);
  }

}

sub flush_ruleset {
  my ($rid,$version) = @_;
  my $rs_key = make_ruleset_key( $rid, $version );
  Kynetx::Memcached::flush_cache($rs_key);
}

sub make_empty_ruleset {
  my ( $rid ) = @_;
  my $json = <<JSON;
{"global":[],"dispatch":[],"ruleset_name":"$rid","rules":[],"meta":{}}
JSON

  return jsonToAst($json);

}

sub make_ruleset_key {
  my ( $rid, $version ) = @_;
  my $logger = get_logger();
  my $opt = Kynetx::Rules::get_optimization_version();
  my $keystring =  "ruleset:$opt:$version:$rid";
  $logger->trace("Keystring: $keystring");
  return md5_base64($keystring);
}

sub is_ruleset_cached { 
  my ( $rid, $version, $memd ) = @_;
  my $rs_key = Kynetx::Repository::make_ruleset_key( $rid, $version );
  # add() returns true if it could store and only stores if not already there
  if ( $memd->add($rs_key, 'not a ruleset') ) {
    $memd->delete($rs_key);
    return 0;
  } else {
    return 1;
  }
}

sub get_ruleset_krl {
    my ($rid_info,$version) = @_; 
    my $logger = get_logger();
    my $fqrid = Kynetx::Rids::get_fqrid($rid_info);
    
    # Check to see if there is a Repository record
    my $repository_record = Kynetx::Persistence::Ruleset::rid_info_from_ruleset($fqrid);
    if ($repository_record) {
      $rid_info = $repository_record;
    }
    my $rid = Kynetx::Rids::get_rid($rid_info);
    $version = Kynetx::Rids::get_version($rid_info) unless ($version);
    my $uri = Kynetx::Rids::get_uri($rid_info);
    if (defined $uri) {
      my $parsed_uri = URI->new($uri);
      my $scheme = $parsed_uri->scheme;
      if ($scheme =~ m/http/) {
        $logger->debug("HTTP repository");
        return Kynetx::Repository::HTTP::get_ruleset($rid_info);
      } elsif ($scheme =~ m/file/) {
        $logger->debug("File repository");
        return Kynetx::Repository::File::get_ruleset($rid_info);
      } elsif ($scheme =~ m/xri/) {
        $logger->debug("XDI repository");
        return Kynetx::Repository::XDI::get_ruleset($rid_info);
      }      
    } else {
        # Try the default repository if $rid_info is not fully configured
        $logger->debug("Check default repository");
        my $repo = Kynetx::Configure::get_config('RULE_REPOSITORY');
        my ($base_url,$username,$password) = split(/\|/, $repo);
        $logger->debug("URL: $base_url");
        my $rs_url = join('/', ($base_url, $rid, $version, 'krl/'));
        $rid_info->{'uri'} = $rs_url;
        $rid_info->{'username'} = $username;
        $rid_info->{'password'} = $password;
        # Populate the RSM with the legacy ruleset
        #Kynetx::Persistence::Ruleset::import_legacy_ruleset(undef,$rid_info);
        return Kynetx::Repository::HTTP::get_ruleset($rid_info);      
    }
    return undef;
}

1;
