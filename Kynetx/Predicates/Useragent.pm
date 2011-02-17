package Kynetx::Predicates::Useragent;
# file: Kynetx/Predicates/Useragent.pm
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
use HTML::ParseBrowser;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_useragent
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (

    'using_ie' => sub {
	my ($req_info, $rule_env, $args) = @_;
	
	return get_useragent($req_info,'browser_name') eq 'MSIE'
	
    },
    
    'using_firefox' => sub {
	my ($req_info, $rule_env, $args) = @_;
	
	return get_useragent($req_info,'browser_name') eq 'Firefox'
	
    },
    

    );


sub get_predicates {
    return \%predicates;
}

# condition subfunctions
# first argument is a record of data about the request

sub get_useragent {
    my ($req_info, $field) = @_;
    # for US locations only right now (with Yahoo!)
    
    my @field_names = qw(
         language
         language_code
         browser_name
         browser_version
         browser_version_major
         browser_version_minor
         os
         os_type
         os_version
	 using_selector
	 selector_name
	 selector_version
         );
    
    my $logger = get_logger();

    if(not defined $req_info->{'useragent'}->{$field}) {

	my $ua_string = $req_info->{'ua'};


	$ua_string =~ s%(infoCard)/(.*)/(\d+\.\d+)%%;
	my($cards, $selector, $version) = ($1, $2, $3);

	$logger->debug("UserAgent: ", $ua_string);
	$logger->debug("Endpoint info:  $cards, $selector, $version");
	my $ua = HTML::ParseBrowser->new($ua_string);


	$req_info->{'useragent'}->{'string'} = $ua_string;
	$req_info->{'useragent'}->{'language'} = $ua->language();
	$req_info->{'useragent'}->{'language_code'} = $ua->lang();
	$req_info->{'useragent'}->{'browser_name'} = $ua->name();
	$req_info->{'useragent'}->{'browser_version'} = $ua->v();
	$req_info->{'useragent'}->{'browser_version_major'} = $ua->major();
	$req_info->{'useragent'}->{'browser_version_minor'} = $ua->minor();
	$req_info->{'useragent'}->{'os'} = $ua->os();
	$req_info->{'useragent'}->{'os_type'} = $ua->ostype();
	$req_info->{'useragent'}->{'os_version'} = $ua->osvers();

	$req_info->{'useragent'}->{'using_selector'} = 
	  ($cards eq 'infoCard') ? 1 : 0;
	$req_info->{'useragent'}->{'selector_name'} = $selector;
	$req_info->{'useragent'}->{'selector_version'} = $version;


    }

    $logger->debug("User-Agent information ($field): " ,
		   $req_info->{'useragent'}->{$field});


    return $req_info->{'useragent'}->{$field};

}



1;
