#!/usr/bin/perl -w

# TODO:
# send original via JS load
# get update via JSON on second JS load

use strict;

use lib qw(/web/lib/perl);


use HTML::Template;
use LWP::Simple;
use XML::XPath;
use Apache2::Request ();


use Kynetx::Predicates::Location qw(get_geoip);
use Kynetx::Predicates::Weather qw(get_weather);

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($DEBUG);

my $r = shift;


my %codes = (
 0 => 	'A tornado<br/> is',
 1 =>	'A tropical storm<br/> is',
 2 =>	'A hurricane<br/> is',
 3 =>	'Severe thunderstorms<br/> are',
 4 =>	'Thunderstorms<br/> are',
 5 =>	'Mixed rain and snow<br/> is',
 6 =>	'Mixed rain and sleet<br/> is',
 7 =>	'Mixed snow and sleet<br/> is',
 8 =>	'Freezing drizzle<br/> is',
 9 =>	'Drizzle<br/> is',
 10=> 	'Freezing rain<br/> is',
 11=> 	'Showers<br/> are',
 12=> 	'Showers<br/> are',
 13=> 	'Snow flurries<br/> are',
 14=> 	'Light snow showers<br/> are',
 15=> 	'Blowing snow<br/> is',
 16=> 	'Snow<br/> is',
 17=> 	'Hail<br/> is',
 18=> 	'Sleet<br/> is',
 19=> 	'Dust<br/> is',
 20=> 	'Foggy<br/> is',
 21=> 	'Haze<br/> is',
 22=> 	'Smoky conditions<br/> are',
 23=> 	'Blustery conditions<br/> are',
 24=> 	'Windy conditions<br/> are',
 25=> 	'Cold<br/> is',
 26=> 	'Cloudy skies<br/> are',
 27=> 	'A mostly cloudy night<br/> is',
 28=> 	'A mostly cloudy day<br/> is',
 29=> 	'A partly cloudy night<br/> is',
 30=> 	'A partly cloudy day<br/> is',
 31=> 	'A clear night<br/> is',
 32=> 	'Sunny conditions<br/> are',
 33=> 	'A fair night<br/> is',
 34=> 	'A fair day<br/> is',
 35=> 	'Mixed rain and hail<br/> is',
 36=> 	'Hot conditions<br/> are',
 37=> 	'Isolated thunderstorms<br/> are',
 38=> 	'Scattered thunderstorms<br/> are',
 39=> 	'Scattered thunderstorms<br/> are',
 40=> 	'Scattered showers<br/> are',
 41=> 	'Heavy snow<br/> is',
 42=> 	'Scattered snow showers<br/> are',
 43=> 	'Heavy snow<br/> is',
 44=> 	'Partly cloudy conditions<br/> are',
 45=> 	'Thundershowers<br/> are',
 46=> 	'Snow showers<br/> are',
 47=> 	'Isolated thundershowers<br/> are',
 3200 => 'not available'
);

my $url = "http://".$r->hostname()."/widgets";

# main page template
my $main_page = <<EOF;
<div id="kobj_weather_1" style="padding:5px;background-color:#FFFFFF; width:194px; text-align:center;">
<div style="padding:5px; background-image:url($url/components/weather/widgetWeatherBk.gif); width:184px; text-align:center; font-size: 14px; font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif;">
<div style="padding:5px; margin:0px; position:relative;" id="kobj_close" onclick="KOBJ.BlindUp('#kobj_weather_1');" align="right" ><img src="$url/components/weather/widgetClose.gif" /></div>
<div id="kobj_weather_2">
<TMPL_IF NAME=forecast>
<span id="kobj_weather_image"><TMPL_VAR NAME=weather_image></span>
<p><span id="kobj_forecast"><TMPL_VAR NAME=forecast></span> forecast for tomorrow in<br/>
<span id="kobj_city"><TMPL_VAR NAME=city></span></p>
<TMPL_ELSE>
<p>Sorry, we can't determine your location to show the weather forecast.</p>
</TMPL_IF>
		
<div id="kobj_weather_3" style="display: none"><form id="zip_form" onSubmit="KOBJ.fragment('<TMPL_VAR NAME=url>?'+\$K(this).serialize());KOBJ.Fade('#kobj_weather_3'); return false"> <label>Please enter your zip code and press return</label><br/> <input id='zip' name="zip" type="text" size="10"/><br/> <input name="redo" value="1" type="hidden"/> </form>
</div>
		
<div style="font-size: 11px; font-family: Arial, Helvetica, sans-serif;" id="kobj_zip" onclick="KOBJ.Fade(this);\$K('#kobj_weather_3').slideDown();">
<TMPL_IF NAME=city>
Not in <TMPL_VAR NAME=city>?<br/>
<span style="color: #3333FF; text-decoration: underline; font-size:11px">Click here</span>
</TMPL_IF>
</div>
</div>
</div>
<div><img src="$url/components/weather/widgetWeatherBtm.gif" /></div>
</div>

EOF
# ' fix 

my $data_page = <<EOF;
KOBJ.update_elements({
      city: '<TMPL_VAR NAME=city>',
      weather_image: '<TMPL_VAR NAME=weather_image>',
      forecast: '<TMPL_VAR NAME=forecast>'
    });

EOF


my ($t, $req_info, $zip, $city, $state, $tc, $img);



if($r->dir_config('run_mode') eq 'development') {
    # WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
#        $r->connection->remote_ip('128.122.108.71'); # New York (NYU)
    $r->connection->remote_ip('72.21.203.1'); # Seattle (Amazon)
#        $r->connection->remote_ip('128.187.16.242'); # Utah (BYU)
} 

$req_info->{'ip'} = $r->connection->remote_ip() || '0.0.0.0';


my $logger = get_logger();
# $logger->debug("IP address: ", $req_info->{'ip'});


my $req = Apache2::Request->new($r);


$zip = $req->param('zip');
$city = $req->param('city');
$state = $req->param('state');
$req_info->{'geoip'}->{'postal_code'} = $zip;
$req_info->{'geoip'}->{'city'} = $city;
$req_info->{'geoip'}->{'region'} = $state;


if(defined $req->param('redo')) {

    $r->content_type('text/javascript');

    $t = HTML::Template->new(scalarref => \$data_page,
			     die_on_bad_params => 0, 
	);

    $logger->debug("Resetting zip: ", $zip);


} else {

    $r->content_type('text/html');


    $t = HTML::Template->new(scalarref => \$main_page,
			     die_on_bad_params => 0, 
	);

    $t->param(url => 'http://' . $r->hostname . $r->uri);
}



$tc = get_weather($req_info,'tomorrow_cond_code');
$city = get_weather($req_info,'city');

$t->param(city => ($city.''));
$t->param(forecast => $codes{$tc});

$img = "<img  src=\"http://l.yimg.com/us.yimg.com/i/us/we/52/$tc.gif\" border=\"0\" hspace=\"3\" vspace=\"3\"  />";

$t->param(weather_image => $img);

print $t->output;



1;

