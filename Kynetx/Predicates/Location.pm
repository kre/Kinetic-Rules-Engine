package Kynetx::Predicates::Location;
# file: Kynetx/Predicates/Location.pm

use strict;
use warnings;

use Geo::IP;
use Log::Log4perl qw(get_logger :levels);

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

    'city' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $city = get_geoip($req_info, 'city');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
        $logger->debug("City: ". $city . " ?= " . $desired);

	return $city eq $desired;
	    
    },

    'outside_city' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $city = get_geoip($req_info, 'city');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes


	my $logger = get_logger();
	$logger->debug("City: ". $city . " ?= " . $desired);

	return !($city eq $desired);
	    
    },

    'state' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $state = get_geoip($req_info, 'region');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
	$logger->debug("State: ". $state . " ?= " . $desired);

	return $state eq $desired;
	    
    },

    'outside_state' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $state = get_geoip($req_info, 'region');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
	$logger->debug("State: ". $state . " ?= " . $desired);

	return !($state eq $desired);
	    
    },
    

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

	if defined $record {
	
	    $logger->debug("GeoIP data for ($field): ", $req_info->{'ip'});

	
	    for my $name (@field_names) {
		$req_info->{'geoip'}->{$name} = $record->$name;
	    }
	} else {
	    $logger->debug("No GeoIP data for ", $req_info->{'ip'});
	    return '';
	}

    }

    return $req_info->{'geoip'}->{$field};

}




1;
