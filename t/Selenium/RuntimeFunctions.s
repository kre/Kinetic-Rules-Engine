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
my $clients = init_selenium_clients();
my $default_url = "http://www.google.com";
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
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["true","true"];
$js = [
	'window.KOBJ.location("protocol") == "http:"',
	'window.KOBJ.location("host") == "www.google.com"'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);


$description = "Check Get Host";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["true"];
$js = [
	'window.KOBJ.get_host("http://www.google.com") == "www.google.com"'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);

$description = "Check Browser Protocol";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["true"];
$js = [
	'window.KOBJ.proto() == "http://"'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);

$description = "Load External Resources";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","OK"];
$js = [
	'window.KOBJ.registerExternalResources("a685x9",{"https://kresources.kobj.net/jquery_ui/1.8/jquery-ui-1.8.4.custom.min.js": {"type":"js"}})',
	{'wait_for_condition' => ['window.KOBJ.external_resources["http://kresources.kobj.net/jquery_ui/1.8/jquery-ui-1.8.4.custom.min.js"].loaded',$LOAD_SHORT]}
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);

$description = "Site ID contains all configured apps";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","true"];
$js = [
	'window.KOBJ.add_app_configs([{rids:["a685x7"]},{rids:["a685x8"]}])',
	'window.KOBJ.site_id() == "a685x9;a685x7;a685x8"',
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);


$description = "Configure Multiple apps";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","true","true"];
$js = [
	'window.KOBJ.add_app_configs([{rids:["a685x7"]},{rids:["a685x8"]}])',
	'window.KOBJ.get_application("a685x7") != null',
	'window.KOBJ.get_application("a685x8") != null'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);



$description = "Run Multiple Apps";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","OK","OK"];
$js = [
	'window.KOBJ.add_config_and_run({"a685x8:kynetx_app_version":"dev",rids:["a685x7","a685x8"]})',
	{'wait_for_element_present' => '//*[@id="kGrowltop-right"]'},
	{'wait_for_condition'=>	['window.$KOBJ(".KOBJ_message").text()=="Hello prod WorldSimple Dev rule."',20]	}
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);

$description = "Run requested app (dev)";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","OK","Simple Dev rule."];
$js = [
	'window.KOBJ.add_config_and_run({"a685x8:kynetx_app_version":"dev",rids:["a685x8"]})',
	{'wait_for_element_present' => '//*[@id="kGrowltop-right"]'},
	{'get_text' => '//div[@class="KOBJ_message"]'}	
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);


$description = "Run requested app (production)";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","OK","Hello prod World"];
$js = [
	'window.KOBJ.add_config_and_run({rids:["a685x7"]})',
	{'wait_for_element_present' => '//*[@id="kGrowltop-right"]'},
	{'get_text' => '//div[@class="KOBJ_message"]'}	
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);



$description = "Generate URL from page vars";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","true"];
$js = [
	'window.KOBJ.add_extra_page_var("test","joe")',
	'(window.KOBJ.extra_page_vars_as_url() == "&test=joe")'];

add_functions_testcase($ridstring,$url,$expected,$description,$js);


$description = "Not a page variable if namespace is init or rids";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","null","true"];
$js = [
	'window.KOBJ.add_extra_page_var("init:test","joe")',
	'window.KOBJ.add_extra_page_var("rids:test","joe")',
	'(window.KOBJ["extra_page_vars"]["init:test"] == null  && window.KOBJ["extra_page_vars"]["rids:test"] == null)'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);


$description = "Add page variable to runtime";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["null","true"];
$js = [
	'window.KOBJ.add_extra_page_var("test","joe")',
	'(window.KOBJ["extra_page_vars"]["test"] == "joe")'
];

add_functions_testcase($ridstring,$url,$expected,$description,$js);


$description = "Get application from runtime";
$ridstring = "a685x9";
$url = "http://www.google.com";
$expected = ["true"];
$js = [
	'(window.KOBJ.get_application("a685x9") != null)'
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