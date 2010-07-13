package Kynetx::Repository;
# file: Kynetx/Repository.pm
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
use SVN::Client;
use APR::URI;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Kynetx::Memcached qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Predicates::Page;
use Kynetx::Rules;

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub get_rules_from_repository{

    my ($rid, $req_info, $localparsing) = @_;

    my $logger = get_logger();


    # default to production for svn repo
    # defaults to production when no version specified
    my $version = Kynetx::Predicates::Page::get_pageinfo($req_info, 'param', ['kynetx_app_version']) || 'prod';
    $req_info->{'rule_version'} = $version;

    my $memd = get_memd();

    my $rs_key = make_ruleset_key($rid, $version);

    # wait if this ruleset's being parsed now
    my $counter;
    while (Kynetx::Memcached::is_parsing($memd, $rs_key) && 
	   $counter < 120 # don't wait forever
	  ) {
      sleep 1;
      $counter++;
    }

    my $ruleset = $memd->get($rs_key);

    if ($ruleset && 
	$ruleset->{'optimization_version'} && 
	$ruleset->{'optimization_version'} >= Kynetx::Rules::get_optimization_version()) {
      $logger->debug("Using cached ruleset for $rid ($version) with key ", make_ruleset_key($rid, $version), " & optimization version ", $ruleset->{'optimization_version'} );

      return $ruleset;
    } 

    my $ext;
    my $krl;
    # defaults to SVN so things keep working
    my $rule_repo_type = 
          Kynetx::Configure::get_config('RULE_REPOSITORY_TYPE') || 'svn';

    my $repo_info = Kynetx::Configure::get_config('RULE_REPOSITORY');

    $logger->debug("Getting rules from repo for $rid using $rule_repo_type");

    # this gets cleared when we're done
    Kynetx::Memcached::set_parsing_flag($memd, $rs_key);

    if ($rule_repo_type eq 'api') {

      my ($base_url,$username,$passwd) = split(/\|/, $repo_info);


      my $parsed_url = APR::URI->parse($req_info->{'pool'}, $base_url);
      my $hostname = $parsed_url->hostname;

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

      my $json;
      if($res->is_success) {
	$json = $res->decoded_content;
      } else {

	$logger->debug("Error retrieving ruleset: ",  $res->status_line);
	# return now to avoid caching fake ruleset
	return make_empty_ruleset($rid, $rs_url);
      }

      if ($localparsing) {
	$ruleset = Kynetx::Parser::parse_ruleset($json);
      } else {
	$ruleset = jsonToAst($json);
      }

    } else { # default is svn
      
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

    }

    Kynetx::Memcached::clr_parsing_flag($memd, $rs_key);

    unless ($ruleset->{'ruleset_name'} eq 'norulesetbythatappid') {
      $ruleset = Kynetx::Rules::optimize_ruleset($ruleset);

      $logger->debug("Found rules for $rid");


      $logger->debug("Caching ruleset for $rid using key $rs_key");
      $memd->set($rs_key, $ruleset);
    } else {
      $logger->error("Ruleset $rid not found");
    }
    return $ruleset;    

}

sub get_svn_conn {
    my($svn_conn) = @_;
    my $logger = get_logger();

    my ($svn_url,$username,$passwd);
    if ($svn_conn) {
	($svn_url,$username,$passwd) = split(/\|/, $svn_conn);
    } else {
	$svn_url = 'svn://127.0.0.1/rules/client/';
	$username = 'web';
	$passwd = 'foobar';
    }

    
    $logger->debug("Connecting to rule repository at $svn_url");


    my $simple_prompt = sub {
	my $cred = shift;
	my $realm = shift;
	my $default_username = shift;
	my $may_save = shift;
	my $pool = shift;

	$cred->username($username);
	$cred->password($passwd);
    };

    # returns a list with the connection and the URL
    # This message:
    # Permission denied: Can't open file '/root/.subversion/servers': Permission denied at /web/lib/perl/Kynetx/Repository.pm line 140\
    # means that the Web server is looking in /root/ instead of /web/ 
    # where it has permissions.  Web server should be started with HOME=/web
    return (new SVN::Client(
		auth => [SVN::Client::get_simple_provider(),
			 SVN::Client::get_simple_prompt_provider($simple_prompt,2),
			 SVN::Client::get_username_provider()]
	    ), 
	    $svn_url)

    

  }

sub make_empty_ruleset {
  my ($rid, $url) = @_;

  my $logger = get_logger();
  $logger->error("Error retrieving $url; returning empty ruleset\n");
  my $json = <<JSON;
{"global":[],"dispatch":[],"ruleset_name":"$rid","rules":[],"meta":{}}
JSON

  return jsonToAst($json);

}

sub make_ruleset_key {
  my ($rid, $version) = @_;
  return "ruleset:$version:$rid";
}


1;
