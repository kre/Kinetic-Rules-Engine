#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);


use LWP::Simple;
use XML::XPath;
use DateTime;


use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Weather qw/:all/;

my $preds = Kynetx::Predicates::Weather::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => (48 * (4 * 5)) + 4 + int(@pnames);



my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


my $ccc = get_weather($BYU_req_info, 'curr_cond_code');
my $tcc = get_weather($BYU_req_info, 'tomorrow_cond_code');


ok(defined($ccc), "Current condition code not undef");
ok(defined($tcc), "Tomorrow's condition code not undef");

ok(&{$preds->{'today_sunny'}}($BYU_req_info) ? 
   (! &{$preds->{'today_cloudy'}}($BYU_req_info)) :  
   1,
   "If it's sunny, it's not cloudy");

ok(&{$preds->{'today_cloudy'}}($BYU_req_info) ? 
   (! &{$preds->{'today_sunny'}}($BYU_req_info)) :  
   1,
   "If it's cloudy, it's not sunny");

foreach my $cc (0..47) {
    # check that these are mutually exclusive
    ok(sunny_cc($cc) ? ! cloudy_cc($cc) : 1, "Sunny isn't cloudy ($cc)");
    ok(sunny_cc($cc) ? ! windy_cc($cc) : 1, "Sunny isn't windy ($cc)");
    ok(sunny_cc($cc) ? ! snow_cc($cc) : 1, "Sunny isn't snowy ($cc)");
    ok(sunny_cc($cc) ? ! showers_cc($cc) : 1, "Sunny isn't showers ($cc)");

    ok(cloudy_cc($cc) ? ! sunny_cc($cc) : 1, "Cloudy isn't sunny ($cc)");
    ok(cloudy_cc($cc) ? ! windy_cc($cc) : 1, "Cloudy isn't windy ($cc)");
    ok(cloudy_cc($cc) ? ! snow_cc($cc) : 1, "Cloudy isn't snowy ($cc)");
    ok(cloudy_cc($cc) ? ! showers_cc($cc) : 1, "Cloudy isn't showers ($cc)");

    ok(windy_cc($cc) ? ! sunny_cc($cc) : 1, "Windy isn't sunny ($cc)");
    ok(windy_cc($cc) ? ! cloudy_cc($cc) : 1, "Windy isn't cloudy ($cc)");
    ok(windy_cc($cc) ? ! snow_cc($cc) : 1, "Windy isn't snowy ($cc)");
    ok(windy_cc($cc) ? ! showers_cc($cc) : 1, "Windy isn't showers ($cc)");

    ok(snow_cc($cc) ? ! sunny_cc($cc) : 1, "Snow isn't sunny ($cc)");
    ok(snow_cc($cc) ? ! cloudy_cc($cc) : 1, "Snow isn't cloudy ($cc)");
    ok(snow_cc($cc) ? ! windy_cc($cc) : 1, "Snow isn't windy ($cc)");
    ok(snow_cc($cc) ? ! showers_cc($cc) : 1, "Snow isn't showers ($cc)");

    ok(showers_cc($cc) ? ! sunny_cc($cc) : 1, "Showers isn't sunny ($cc)");
    ok(showers_cc($cc) ? ! cloudy_cc($cc) : 1, "Showers isn't cloudy ($cc)");
    ok(showers_cc($cc) ? ! windy_cc($cc) : 1, "Showers isn't windy ($cc)");
    ok(showers_cc($cc) ? ! snow_cc($cc) : 1, "Showers isn't snow ($cc)");



}

1;


