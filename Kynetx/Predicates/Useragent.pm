package Kynetx::Predicates::Useragent;
# file: Kynetx/Predicates/Useragent.pm
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
	$logger->debug("Endpoint info:  ",$cards,", ", $selector,", ", $version);
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
