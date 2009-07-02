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


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Kynetx::Memcached qw(:all);
use Kynetx::Json qw(:all);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_rules_from_repository
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub get_rules_from_repository{

    my ($site, $svn_conn, $request_info) = @_;

    my $logger = get_logger();

    my $memd = get_memd();

    my $ruleset = $memd->get("ruleset:$site");
    if ($ruleset) {
	$request_info->{'rule_version'} = $memd->get("ruleset_version:$site");
	$logger->debug("Using cached ruleset for $site");
	return $ruleset;
    } 


    my ($ctx, $svn_url) = get_svn_conn($svn_conn);

    my %d;
    my $info = sub {
	my( $path, $info, $pool ) = @_;
	$d{$path} = $info->last_changed_rev();
    };

    my $ext;
    foreach $ext ('.krl','.json') {
	my $svn_path = $svn_url.$site.$ext;
	eval {
	    $logger->debug("Getting info on ", $svn_path);
	    $ctx->info($svn_path, 
		       undef,
		       'HEAD',
		       $info,
		       0           # don't recurse
		);
	};
	if($@) {  # catch file doesn't exist...
#	    $logger->debug($svn_path, " returned error ", $@);
	    $d{$site.$ext} = -1;
	}
    }

    if ($d{$site.'.krl'} eq -1 && $d{$site.'.json'} eq -1) {
	$logger->debug("Ruleset $site not found; returning fake ruleset");
	return Kynetx::Parser::parse_ruleset("ruleset $site {}");
    }


    if($d{$site.'.krl'} > $d{$site.'.json'}) {
	$ext = '.krl';
    } else {
	$ext = '.json';
    }

    $request_info->{'rule_version'} = $d{$site.$ext};
    $logger->debug("Using the $ext version: ", $request_info->{'rule_version'});
    

    # open a variable as a filehandle (for weird SVN::Client stuff)
    my $krl;
    open(FH, '>', \$krl) or die "Can't open memory file: $!";
    $ctx->cat (\*FH,
	       $svn_url.$site.$ext, 
	       'HEAD');

    $logger->debug("Found rules for $site");

    # return the abstract syntax tree regardless of source
    if($ext eq '.krl') {
	$ruleset = Kynetx::Parser::parse_ruleset($krl);
    } else {
	$ruleset = jsonToAst($krl);
    }



    $logger->debug("Caching ruleset for $site");
    $memd->set("ruleset:$site", $ruleset);
    $memd->set("ruleset_version:$site", $request_info->{'rule_version'});
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
	$username = 'foobar';
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


1;
