package Kynetx::Predicates::Weather;
# file: Kynetx/Predicates/Weather.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my %predicates = (
    'warmer' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];
    
	my $temp = get_weather($req_info, 'curr_temp');

	my $logger = get_logger();
	$logger->debug("Weather for zip: " . 
		       $req_info->{'geoip'}->{'postal_code'} . 
		       " " . int($temp) . " ?> " . $desired);

	return int($temp) > $desired;

    },


    'tomorrow_cond' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	my $logger = get_logger();
	$logger->debug("Weather for zip: " . 
		       $req_info->{'geoip'}->{'postal_code'} . 
		       " " . int($tcond) . " ?= " . $desired);

	return int($tcond) == $desired;
   
    
    },

    'tomorrow_showers' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	return 
	    int($tcond) == 4 ||
	    int($tcond) == 6 || 
	    int($tcond) == 9 || 
	    int($tcond) == 11 || 
	    int($tcond) == 12;
   

    },

    'tomorrow_cloudy' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	return 
	    int($tcond) == 26 ||
	    int($tcond) == 27 || 
	    int($tcond) == 28|| 
	    int($tcond) == 29 || 
	    int($tcond) == 30 || 
	    int($tcond) == 44;
   

    },

    'tomorrow_snow' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	return 
	    int($tcond) == 5 ||
	    int($tcond) == 7 || 
	    int($tcond) == 13 || 
	    int($tcond) == 14 || 
	    int($tcond) == 15 || 
	    int($tcond) == 16 || 
	    int($tcond) == 18 ||
	    int($tcond) == 42 ||
	    int($tcond) == 43 ||
	    int($tcond) == 46
	    ;
	
    },

    );


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
	    $curr_cond->find('@temp'); 
	$req_info->{'weather'}->{'curr_cond'} = 
	    $curr_cond->find('@text'); 
	$req_info->{'weather'}->{'curr_cond_cond'} = 
	    $curr_cond->find('@code'); 
	$req_info->{'weather'}->{'timezone'} = 
	    $curr_cond->find('@date'); 
	$req_info->{'weather'}->{'timezone'} =~ s/.*(\w\w\w)$/$1/;


	my @forecast_cond = 
	      $rss->find('/rss/channel/item/yweather:forecast')->get_nodelist;

	$req_info->{'weather'}->{'tomorrow_low'} = 
	    $forecast_cond[0]->find('@low'); 
	$req_info->{'weather'}->{'tomorrow_high'} = 
	    $forecast_cond[0]->find('@high'); 
	$req_info->{'weather'}->{'tomorrow_cond'} = 
	    $forecast_cond[0]->find('@text'); 
	$req_info->{'weather'}->{'tomorrow_cond_code'} = 
	    $forecast_cond[0]->find('@code'); 
	

	my $astronomy = 
	    $rss->find('/rss/channel/yweather:astronomy')->get_node(1);

	$req_info->{'weather'}->{'sunrise'} = 
	    $$astronomy->find('@sunrise'); 
	$req_info->{'weather'}->{'sunset'} = 
	    $astronomy->find('@sunset'); 





    }

    $logger->debug("Weather for zip ($field): " ,
		   $req_info->{'geoip'}->{'postal_code'},
		   " -> ", 
		   $req_info->{'weather'}->{$field});


    return $req_info->{'weather'}->{$field};

}



1;
