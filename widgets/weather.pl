#!/usr/bin/perl -w

# TODO:
# send original via JS load
# get update via JSON on second JS load

use strict;

use lib qw(/web/lib/perl);


use CGI;
use HTML::Template;
use LWP::Simple;
use XML::XPath;


use Kynetx::Predicates::Location qw(get_geoip);
use Kynetx::Predicates::Weather qw(get_weather);
use Kynetx::Session qw(:all);

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($DEBUG);



my $q = CGI->new();


my %codes = (
 0 => 	'A tornado is',
 1 =>	'A tropical storm is',
 2 =>	'A hurricane is',
 3 =>	'Severe thunderstorms are',
 4 =>	'Thunderstorms are',
 5 =>	'Mixed rain and snow is',
 6 =>	'Mixed rain and sleet is',
 7 =>	'Mixed snow and sleet is',
 8 =>	'Freezing drizzle is',
 9 =>	'Drizzle is',
 10=> 	'Freezing rain is',
 11=> 	'Showers are',
 12=> 	'Showers are',
 13=> 	'Snow flurries are',
 14=> 	'Light snow showers are',
 15=> 	'Blowing snow is',
 16=> 	'Snow is',
 17=> 	'Hail is',
 18=> 	'Sleet is',
 19=> 	'Dust is',
 20=> 	'Foggy is',
 21=> 	'Haze is',
 22=> 	'Smoky conditions are',
 23=> 	'Blustery conditions are',
 24=> 	'Windy conditions are',
 25=> 	'Cold is',
 26=> 	'Cloudy skies are',
 27=> 	'A mostly cloudy night is',
 28=> 	'A mostly cloudy day is',
 29=> 	'A partly cloudy night is',
 30=> 	'A partly cloudy day is',
 31=> 	'A clear night is',
 32=> 	'Sunny conditions are',
 33=> 	'A fair night is',
 34=> 	'A fair day is',
 35=> 	'Mixed rain and hail is',
 36=> 	'Hot conditions are',
 37=> 	'Isolated thunderstorms are',
 38=> 	'Scattered thunderstorms are',
 39=> 	'Scattered thunderstorms are',
 40=> 	'Scattered showers are',
 41=> 	'Heavy snow is',
 42=> 	'Scattered snow showers are',
 43=> 	'Heavy snow is',
 44=> 	'Partly cloudy conditions are',
 45=> 	'Thundershowers are',
 46=> 	'Snow showers are',
 47=> 	'Isolated thundershowers are',
 3200 => 'not available'
);

my $main_page = <<'EOF';

<div 
id="kobj_weather_1"
style="padding: 3pt;
  border: solid 1pt black;
  background-color: #FFFFCC;
  width: 150px;
  text-align: center">

<div id="kobj_weather_2">

<p>
<span id="kobj_forecast"><TMPL_VAR NAME=forecast></span>
forecast for tomorrow in<br/> 
<span id="kobj_city"><TMPL_VAR NAME=city></span>
</p>

<p>
<span id="kobj_weather_image"> 
<TMPL_VAR NAME=weather_image>
</span>
</p>

<div id="kobj_weather_3" style="display: none">
<form id="zip_form" onSubmit="KOBJ.fragment('<TMPL_VAR NAME=url>?'+this.serialize());new Effect.Fade($('kobj_weather_3')); return false">
<label>Please enter your zip code and press return</label><br/>
<input id='zip' name="zip"/ type="text" size="10"><br/>
    </form>

</div>

<div style="color: #3333FF; text-decoration: underline" id="kobj_zip" onclick="new Effect.Fade(this);new Effect.BlindDown($('kobj_weather_3'));Form.focusFirstElement('zip_form');">Not in <TMPL_VAR NAME=city>?</div>

<div style="color: #3333FF; text-decoration: underline" id="kobj_close" onclick="new Effect.BlindUp($('kobj_weather_1'));">close</div>

</div>
</div>

EOF


my $data_page = <<'EOF';
KOBJ.update_elements({
      city: '<TMPL_VAR NAME=city>',
      weather_image: '<TMPL_VAR NAME=weather_image>',
      forecast: '<TMPL_VAR NAME=forecast>'
    });

EOF


my ($t, $req_info, $zip);

#$req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon) for testing
$req_info->{'ip'} = $q->remote_addr();


my $logger = get_logger();
$logger->debug("IP address: ", $req_info->{'ip'});

$zip = get_geoip($req_info,'postal_code');


if(defined $q->param('zip')) {

    print $q->header(-Content_type => 'text/javascript');

    $t = HTML::Template->new(scalarref => \$data_page,
			     die_on_bad_params => 0, 
	);

    $req_info->{'geoip'}->{'postal_code'} = $q->param('zip');

} else {

    print $q->header();

    $t = HTML::Template->new(scalarref => \$main_page,
			     die_on_bad_params => 0, 
	);

    $t->param(url => $q->url());
}

my $tc = get_weather($req_info,'tomorrow_cond_code');
my $city = get_weather($req_info,'city');

$t->param(city => ($city.''));
$t->param(forecast => $codes{$tc});

my $img = "<img  src=\"http://l.yimg.com/us.yimg.com/i/us/we/52/$tc.gif\" border=\"0\" hspace=\"3\" vspace=\"3\"  />";

$t->param(weather_image => $img);

print $t->output;



1;

my $foo = <<'EOF';

$('zip').getValue()

KOBJ.fragment('<TMPL_VAR NAME=url>?zip='+\$(zip).getValue());

<form id="zip_form" onSubmit="new Ajax.Updater('kobj_weather_1', '/cgi-bin/weather.cgi', {method: 'get',  parameters: this.serialize() });	new Effect.Fade($('kobj_weather_3')); return false}">
EOF

