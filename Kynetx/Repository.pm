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
use Kynetx::Repository::HTTP;
use Kynetx::Repository::File;
use Kynetx::Repository::XDI;

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

<<<<<<< HEAD
    # default to production for svn repo
    # defaults to production when no version specified
    # use specified version first

#    $logger->debug("req_info: ", sub { Dumper $req_info });
    my $version = $sversion || 
                    get_version($rid_info) ||
		      Kynetx::Predicates::Page::get_pageinfo($req_info, 'param', [$rid.':kynetx_app_version']) || 
			  Kynetx::Predicates::Page::get_pageinfo($req_info, 'param', [$rid.':kinetic_app_version']) || 
		  'prod';
    $req_info->{'rule_version'} = $version;
=======
  my ( $rid_info, $req_info, $sversion, $localparsing, $text ) = @_;
>>>>>>> github10

  my $logger = get_logger();

  my $rid = get_rid($rid_info);

  # default to production for svn repo
  # defaults to production when no version specified
  # use specified version first
  my $version =
       $sversion
    || get_version($rid_info)
    || Kynetx::Predicates::Page::get_pageinfo( $req_info, 'param',
    ['kynetx_app_version'] )
    || Kynetx::Predicates::Page::get_pageinfo( $req_info, 'param',
    ['kinetic_app_version'] )
    || 'prod';
  $req_info->{'rule_version'} = $version;

  my $memd = get_memd();

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
    $logger->info("Parsing semaphore hold: $counter") if ( $counter % 2 ) == 0;
  }

  my $ruleset = $memd->get($rs_key);

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
  my $uri = get_uri($rid_info);
  my $result;
  
  if (defined $uri) {
    my $parsed_uri = APR::URI->parse($req_info->{'pool'}, $uri);
    my $scheme = $parsed_uri->scheme;
    if ($scheme =~ m/http/) {
      $logger->debug("HTTP repository");
      $ruleset = Kynetx::Repository::HTTP::get_ruleset($rid_info);
    } elsif ($scheme =~ m/file/) {
      $logger->debug("File repository");
      $ruleset = Kynetx::Repository::File::get_ruleset($rid_info);
    } elsif ($scheme =~ m/xri/) {
      $logger->debug("XDI repository");
      $ruleset = Kynetx::Repository::XDI::get_ruleset($rid_info);
    }
<<<<<<< HEAD
#     if ($ruleset &&
# 	$ruleset->{'optimization_version'} &&
# 	$ruleset->{'optimization_version'} < Kynetx::Rules::get_optimization_version()) {
#       $localparsing = 1;
#     }
# let's force local parsing...
    $localparsing = 1;

    my $ext;
    my $krl;
    # defaults to file
    my $rule_repo_type =
          Kynetx::Configure::get_config('RULE_REPOSITORY_TYPE') || 'file';

    my $repo_info = Kynetx::Configure::get_config('RULE_REPOSITORY');

    $logger->debug("Getting rules from repo for $rid using $rule_repo_type");

    # this gets cleared when we're done
    $logger->debug("Setting parsing semaphore for $rs_key");
    Kynetx::Memcached::set_parsing_flag($memd, $rs_key);

    if ($rule_repo_type eq 'api') {

      my ($base_url,$username,$passwd) = split(/\|/, $repo_info);


      # my $parsed_url = APR::URI->parse($req_info->{'pool'}, $base_url);
      # my $hostname = $parsed_url->hostname;

      my $hostname = Kynetx::Util::get_host($base_url);

      # FIXME: this ought to be using code from Memcached.pm
      #        that requires refactoring svn code below and fixing
      #        flush_ruleset_cache

      # grab json version on the bet that more code in repo is in that format
      # final '' ensures a trailing slash

      my $res_type;
      if ($localparsing) {
	$res_type = 'krl';
      } else {
	$res_type = 'json';
      }

      my $rs_url = join('/', ($base_url, $rid, $version, $res_type, ''));

      $logger->debug("Using API to retrieve $rs_url");

      my $ua = LWP::UserAgent->new;
      $ua->agent("Kynetx Rule Engine/1.0");

      my $req = HTTP::Request->new(GET => $rs_url);
      $req->authorization_basic($username, $passwd);

      my $res = $ua->request($req);
#      $logger->debug("URL: ",$rs_url);

      my $result;
      if($res->is_success) {
	$result = encode("UTF-8",$res->decoded_content);
      } else {

	$logger->debug("Error retrieving ruleset: ",  $res->status_line);
	# return now to avoid caching fake ruleset

	$logger->debug("Clearing parsing semaphore for $rs_key");
	Kynetx::Memcached::clr_parsing_flag($memd, $rs_key);
	return make_empty_ruleset($rid, $rs_url);
      }

      if ($text) {
	$logger->debug("Clearing parsing semaphore for $rs_key");
	Kynetx::Memcached::clr_parsing_flag($memd, $rs_key);
        return $result;
      } elsif ($localparsing) {
	$ruleset = Kynetx::Parser::parse_ruleset($result);
      } else {
	$ruleset = jsonToAst($result);
      }

    } elsif ($rule_repo_type eq 'svn') {

      require SVN::Client;
      SVN::Client->import;


      # FIXME: all this complicated SVN code could be replaced by nicer WebDAV
      #        code and refactored to work with code from Memcached.pm

      my ($ctx, $svn_url) = get_svn_conn($repo_info);
      $svn_url .= '/' unless $svn_url =~ m#/$#;

      my %d;
      my $info = sub {
	my( $path, $info, $pool ) = @_;
	$d{$path} = $info->last_changed_rev();
      };

      my $svn_path;
      foreach $ext ('.krl','.json') {
	$svn_path = $svn_url.$rid.$ext;
	eval {
	  $logger->debug("Getting info on ", $svn_path);
	  $ctx->info($svn_path,
		     undef,
		     'HEAD',
		     $info,
		     0		# don't recurse
		    );
	};
	if ($@) {		# catch file doesn't exist...
	  #	    $logger->debug($svn_path, " returned error ", $@);
	  $d{$rid.$ext} = -1;
	}
      }

      if ($d{$rid.'.krl'} eq -1 && $d{$rid.'.json'} eq -1) {
	# return now to avoid caching fake ruleset
	return make_empty_ruleset($rid, $svn_path);
      }


      if ($d{$rid.'.krl'} > $d{$rid.'.json'}) {
	$ext = '.krl';
      } else {
	$ext = '.json';
      }

      $req_info->{'rule_version'} = $d{$rid.$ext};
      $logger->debug("Using the $ext version: ", $req_info->{'rule_version'});

      # open a variable as a filehandle (for weird SVN::Client stuff)
      open(FH, '>', \$krl) or die "Can't open memory file: $!";
      $ctx->cat (\*FH,
		 $svn_url.$rid.$ext,
		 'HEAD');

      # return the abstract syntax tree regardless of source
      if($ext eq '.krl') {
	$ruleset = Kynetx::Parser::parse_ruleset($krl);
      } else {
	$ruleset = jsonToAst($krl);
      }

    } else { # default to file
=======
>>>>>>> github10
    
  } else {
    # Try the default repository if $rid_info is not fully configured
    $logger->debug("Check default repository");
    my $repo = Kynetx::Configure::get_config('RULE_REPOSITORY');
    my ($base_url,$username,$password) = split(/\|/, $repo);
    $logger->trace("URL: $base_url");
    my $rs_url = join('/', ($base_url, $rid, $version, 'krl/'));
    $rid_info->{'uri'} = $rs_url;
    $rid_info->{'username'} = $username;
    $rid_info->{'password'} = $password;
    $logger->trace("Rid info: ", sub {Dumper($rid_info)});
    $ruleset = Kynetx::Repository::HTTP::get_ruleset($rid_info);
    
  }
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
          $logger->error("Ruleset parsing error for $rid: ", sub {Dumper ($ruleset->{'error'})});
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

sub flush {
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
  my $opt = Kynetx::Rules::get_optimization_version();
  my $keystring =  "ruleset:$opt:$version:$rid";
  return md5_base64($keystring);
}

1;
