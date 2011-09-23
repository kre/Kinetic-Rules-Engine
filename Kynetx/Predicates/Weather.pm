package Kynetx::Predicates::Weather;
# file: Kynetx/Predicates/Weather.pm
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
use XML::XPath;
use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Predicates::Location qw(get_geoip);



use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_weather
sunny_cc
windy_cc
snow_cc
showers_cc
cloudy_cc
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my %predicates = (
    'warmer_than' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];
    
	my $temp = get_weather($req_info, 'curr_temp');

	my $logger = get_logger();
	$logger->debug("Weather for zip: " . 
		       $req_info->{'geoip'}->{'postal_code'} . 
		       " " . int($temp) . " ?> " . $desired);

	return int($temp) > $desired;

    },


    'today_showers' => sub {
	my ($req_info, $rule_env, $args) = @_;

	return showers_cc(get_weather($req_info, 'curr_cond_code'));
   

    },

    'tomorrow_showers' => sub {
	my ($req_info, $rule_env, $args) = @_;

	return showers_cc(get_weather($req_info, 'tomorrow_cond_code'));
   

    },

    'today_cloudy' => sub {
	my ($req_info, $rule_env, $args) = @_;

	return cloudy_cc(get_weather($req_info, 'curr_cond_code'));
   

    },

    'tomorrow_cloudy' => sub {
	my ($req_info, $rule_env, $args) = @_;

	return cloudy_cc(get_weather($req_info, 'tomorrow_cond_code'));
   

    },

    'today_snow' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	return snow_cc(get_weather($req_info, 'curr_cond_code'));
	
    },

    'tomorrow_snow' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	return snow_cc(get_weather($req_info, 'tomorrow_cond_code'));
	
    },

    'today_windy' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	return windy_cc(get_weather($req_info, 'curr_cond_code'));
	
    },

    'tomorrow_windy' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	return windy_cc(get_weather($req_info, 'tomorrow_cond_code'));
	
    },

    'today_sunny' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	return sunny_cc(get_weather($req_info, 'curr_cond_code'));
	
    },

    'tomorrow_sunny' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	return sunny_cc(get_weather($req_info, 'tomorrow_cond_code'));
	
    },

    );

# need predicates already defined for this
$predicates{'colder_than'} = sub {
    return ! $predicates{'warmer_than'}(@_)

};



sub get_predicates {
    return \%predicates;
}


# condition subfunctions
# first argument is a record of data about the request

sub get_weather {
    my ($req_info, $field) = @_;

    # for US locations only right now (with Yahoo!)
    
    my @field_names = qw(
          curr_temp
          curr_cond
          curr_cond_code
          tomorrow_low
          tomorrow_high
          tomorrow_cond
          tomorrow_cond_code
         );
    
    my $logger = get_logger();

    if(not defined $req_info->{'weather'}->{$field}) {


	my $zip = get_geoip($req_info, 'postal_code');


	# FIXME: urls are hardcoded in this function
	# FIXME: expirations are hardcoded here

	# if we don't get a 5 digit zip, then look up the location code
	if ($zip !~ m/^\d\d\d\d\d$/) {

	    my $city = get_geoip($req_info, 'city');
	    my $region = get_geoip($req_info, 'region');
	    my $country_name = get_geoip($req_info, 'country_name');
	    my $country_code = get_geoip($req_info, 'country_code');
	    $logger->debug("[weather] $city, $region, $zip, $country_name");

	    my $url = "http://xoap.weather.com/weather/search/search?where=";
	    if ($country_code eq 'US') {
		$url .= "$city%20$region";
	    } else {
		$url .= "$city%20$country_name";
	    }
	    my $locxml = new XML::XPath->new(
		xml => 
		get_remote_data($url, 60 * 60 * 24 * 29) # expire after 29 days
		);
	    # grab the first location ID
	    $zip = $locxml->find('//loc[1]/@id');
	    $logger->debug("[weather] Using code $zip for ZIP");
	    
	}

	# FIXME: farenhiet hardwided in.  Should come from client
	my $url = 'http://xml.weather.yahoo.com/forecastrss?p='. $zip . '&u=f';
	my $content = get_remote_data($url, 60*60*12); # expire after 12 hours

	my $rss = new XML::XPath->new(xml => $content);


	my $curr_cond = 
	    $rss ->find('/rss/channel/item/yweather:condition')->get_node(1);



	return unless $curr_cond; # fails

	$req_info->{'weather'}->{'curr_temp'} = 
	    $curr_cond->find('@temp')->string_value(); 
	$req_info->{'weather'}->{'curr_cond'} = 
	    $curr_cond->find('@text')->string_value(); 
	$req_info->{'weather'}->{'curr_cond_code'} = 
	    $curr_cond->find('@code')->string_value(); 
	$req_info->{'weather'}->{'timezone'} = 
	    $curr_cond->find('@date')->string_value(); 
	$req_info->{'weather'}->{'timezone'} =~ s/.*(\w\w\w)$/$1/;



	my @forecast_cond = 
	      $rss->find('/rss/channel/item/yweather:forecast')->get_nodelist;

	$req_info->{'weather'}->{'tomorrow_low'} = 
	    $forecast_cond[0]->find('@low')->string_value(); 
	$req_info->{'weather'}->{'tomorrow_high'} = 
	    $forecast_cond[0]->find('@high')->string_value(); 
	$req_info->{'weather'}->{'tomorrow_cond'} = 
	    $forecast_cond[0]->find('@text')->string_value(); 
	$req_info->{'weather'}->{'tomorrow_cond_code'} = 
	    $forecast_cond[0]->find('@code')->string_value(); 
	

	my $astronomy = 
	    $rss->find('/rss/channel/yweather:astronomy')->get_node(1);

	$req_info->{'weather'}->{'sunrise'} = 
	    $astronomy->find('@sunrise')->string_value(); 
	$req_info->{'weather'}->{'sunset'} = 
	    $astronomy->find('@sunset')->string_value(); 


	my $location = 
	    $rss ->find('/rss/channel/yweather:location')->get_node(1);
	$req_info->{'weather'}->{'city'} = 
	    $location->find('@city')->string_value(); 
	$req_info->{'weather'}->{'region'} = 
	    $location->find('@region')->string_value(); 
	$req_info->{'weather'}->{'country'} = 
	    $location->find('@country')->string_value(); 



    }

    $logger->debug("Weather for zip ($field): " ,
		   $req_info->{'geoip'}->{'postal_code'},
		   " -> ", 
		   $req_info->{'weather'}->{$field});


    return $req_info->{'weather'}->{$field};

}


sub snow_cc {
    my($cond_code) = @_;

    my $logger = get_logger();

    $cond_code = int($cond_code);

    return 
	$cond_code == 5 ||
	$cond_code == 7 || 
	$cond_code == 13 || 
	$cond_code == 14 || 
	$cond_code == 15 || 
	$cond_code == 16 || 
	$cond_code == 18 ||
	$cond_code == 42 ||
	$cond_code == 43 ||
	$cond_code == 46;
}

sub showers_cc {
    my($cond_code) = @_;

    my $logger = get_logger();

    $cond_code = int($cond_code);

    return
	$cond_code == 4 ||
	$cond_code == 6 || 
	$cond_code == 9 || 
	$cond_code == 11 || 
	$cond_code == 12;

}

sub cloudy_cc {
    my($cond_code) = @_;

    my $logger = get_logger();

    $cond_code = int($cond_code);

    return
	$cond_code == 26 ||
	$cond_code == 27 || 
	$cond_code == 28|| 
	$cond_code == 29 || 
	$cond_code == 30 || 
	$cond_code == 44;

}

sub sunny_cc {
    my($cond_code) = @_;

    my $logger = get_logger();

    $cond_code = int($cond_code);

    return
	$cond_code == 31 ||
	$cond_code == 32 || 
	$cond_code == 33 || 
	$cond_code == 34;

}

sub windy_cc {
    my($cond_code) = @_;

    my $logger = get_logger();

    $cond_code = int($cond_code);

    return
	$cond_code == 23 ||
	$cond_code == 24;

}


1;
