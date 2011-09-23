package Kynetx::Predicates::Location;
# file: Kynetx/Predicates/Location.pm
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
