package Kynetx::Predicates::Location;
# file: Kynetx/Predicates/Location.pm
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

use Geo::IP;
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;

use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw( 
get_geoip
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (

    );


sub get_predicates {
    return \%predicates;
}

# condition subfunctions
# first argument is a record of data about the request

sub get_geoip {
    # $field is on of the valid GeoIP record field names
    my ($req_info, $field) = @_;

    my @field_names = qw(
	    country_code
            country_code3
            country_name
            region
            city
            postal_code
            latitude
            longitude
            dma_code
            area_code);

    # FIXME: hard coded URL
    
    if(not defined $req_info->{'geoip'}->{$field}) {

	my $gi = Geo::IP->open("/web/share/GeoIP/GeoIPCity.dat", 
			       Geo::IP::GEOIP_STANDARD);

	my $record = $gi->record_by_addr($req_info->{'ip'});
    my $logger = get_logger();
	
	$logger->debug("Requesting GeoIP information for : ", $req_info->{'ip'});


	if (defined $record) {
	
	    $logger->debug("GeoIP data for ($field): ", $record->$field);

	
	    for my $name (@field_names) {
		$req_info->{'geoip'}->{$name} = $record->$name;
	    }

	    # add some more common names
	    $req_info->{'geoip'}->{'state'} = 
		$req_info->{'geoip'}->{'region'};
	    $req_info->{'geoip'}->{'zip'} = 
		$req_info->{'geoip'}->{'postal_code'};
	    

	} else {
	    $logger->debug("No GeoIP data for ", $req_info->{'ip'});
	    return '';
	}

    }

    return $req_info->{'geoip'}->{$field};

}




1;
