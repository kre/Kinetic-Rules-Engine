#!/usr/bin/perl -w

use lib qw(/web/lib/perl);

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium qw(wait_for_element_present);
use Test::More "no_plan";
use Test::Deep;
use Test::Exception;
use Data::Dumper;
use YAML::XS;

use t::Selenium::Selenium qw(:all);

use Log::Log4perl::Level;
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($WARN);
Log::Log4perl->easy_init($DEBUG);

my $logger = get_logger();

use Kynetx::Configure qw/:all/;
use constant CMODULE => 'SELENIUM';

# New reference uses the default YML file from Configure.pm
Kynetx::Configure::configure();

# Run mode determines what the next level of verification on config
# variables beyond existance
# Valid options are (production|development)
my $runmode = Kynetx::Configure::get_config('RUN_MODE');

$runmode = 'qa';

BAIL_OUT('Config variable RUN_MODE must be defined in the kns_config')
  unless ($runmode);
  
my $selenium_config = Kynetx::Configure::get_config("SELENIUM");

BAIL_OUT('Config variable SELENIUM must be defined in the kns_config')
  unless ($selenium_config);


$logger->info("Test Mode: $runmode");



my $sconfig = make_selenium_config($runmode);
my $default_url = "http://www.google.com";
my $clients = init_selenium_clients($default_url);
my $INTERVAL = 500;
my $LOAD_SHORT = 10000;
my $LOAD_LONG = 30000;


my (@functions_testcases);

sub add_functions_testcase {
	my ($ridstring,$url,$expected,$description,$js) = @_;
	my $test_case = {};
	$test_case->{'ridstring'} = $ridstring;
	$test_case->{'url'}= $url;
	$test_case->{'expected'} = $expected;
	$test_case->{'description'}= $description;
	$test_case->{'js'} = $js;
	push(@functions_testcases,$test_case);
}

sub init_testcase {
	my ($client, $bookmarklet, $durl) = @_;
	my $url = $durl || $default_url;
	$client->open($url);
	$client->set_speed($INTERVAL);
	$client->wait_for_page_to_load($LOAD_SHORT);
	$client->get_eval($bookmarklet);
	$client->wait_for_condition("typeof(window.\$KOBJ) != 'undefined'",$LOAD_SHORT);
}

my ($ridstring,$url,$expected,$description,$js);

# JS Functions perform as expected
$description = "Check location";
$ridstring = "a144x115";
$url = "http://www.google.com";
$expected = ["OK","true"];
$js = [
	{'set_timeout' => 60000},
	'window.KOBJ.get_application("a144x115") != null', 
	{'wait_for_element_present' => '//*[@id="kGrowltop-right"]'},
	'window.$KOBJ(".KOBJ_message").text()'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);





foreach my $browser_platform (keys %$clients) {
	my $c = $clients->{$browser_platform};
	foreach my $test_case (@functions_testcases) {
		my $rstring = $test_case->{'ridstring'};
		my $url = $test_case->{'url'};
		my @results = ();
		my @expected = @{$test_case->{'expected'}};
		my $description = $test_case->{'description'};
		init_testcase($c,bookmarklet_js($sconfig,$rstring,$url));
		my @steps = @{$test_case->{'js'}};
		foreach my $step (@steps) {
			my $res;
			if (ref $step eq "HASH") {
				# Selenium function
				$logger->debug("Step: ", sub {Dumper($step)});
				my ($key,$target) = each %$step;
				if (ref $target eq "ARRAY") {
					$res = $c->$key(@$target);
				} else {
					$res = $c->$key($target);
				}		
				
			} else {				
				$res = $c->get_eval($step);
			}
			$logger->debug("Result: ", sub {Dumper($res)});
			push(@results,$res);
		}
#		$logger->debug("Expected: ", sub {Dumper(@expected)});
#		$logger->debug("Results: ", sub {Dumper(@results)});
		cmp_deeply(\@results,set(@expected),$description);
	}
}



destroy_selenium_clients($clients);

1;