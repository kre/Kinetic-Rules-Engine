#!/usr/bin/perl -w

use lib qw(/web/lib/perl);

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
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


my ($description,$eval_string,$expected,$runtime_js,$js,$search_url,$bm);
my (@runtime_testcases,@search_annotation_testcases);


sub add_runtime_testcase {
	my ($description, $eval_string,$expected) = @_;
	push(@runtime_testcases, {
		'desc' => $description,
		'eval' => $eval_string,
		'expt' => $expected
	});
}

# Runtime Test Cases
## Functions defined
$eval_string = "'' + (typeof(window.KOBJ.log) != 'undefined')";
$description = "have defined a function called KOBJ.log";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$eval_string = "'' + (typeof(window.KOBJ.css)  != 'undefined')";
$description = "have defined a function called KOBJ.css";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$eval_string = "'' + (typeof(window.KOBJ.errorstack_submit)  != 'undefined')";
$description = "have defined a function called KOBJ.errorstack_submit";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.logger";
$eval_string = "'' + (typeof(window.KOBJ.logger)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.obs";
$eval_string = "'' + (typeof(window.KOBJ.obs)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.fragment";
$eval_string = "'' + (typeof(window.KOBJ.fragment)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);		             

$description = "have defined a function called KOBJ.update_elements";
$eval_string = "'' + (typeof(window.KOBJ.update_elements)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.Fade";
$eval_string = "'' + (typeof(window.KOBJ.Fade)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "Function KOBJ.ContactlessNot is not defined";
$eval_string = "'' + (typeof(window.KOBJ.ContactlessNot)  != 'undefined')";
$expected = "false";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.BlindDown";
$eval_string = "'' + (typeof(window.KOBJ.BlindDown)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.BlindUp";
$eval_string = "'' + (typeof(window.KOBJ.BlindUp)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.BlindUp";
$eval_string = "'' + (typeof(window.KOBJ.BlindUp)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.hide";
$eval_string = "'' + (typeof(window.KOBJ.hide)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.letitsnow";
$eval_string = "'' + (typeof(window.KOBJ.letitsnow)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.createPopIn";
$eval_string = "'' + (typeof(window.KOBJ.createPopIn)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.statusbar";
$eval_string = "'' + (typeof(window.KOBJ.statusbar)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.statusbar_close";
$eval_string = "'' + (typeof(window.KOBJ.statusbar_close)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.buildDiv";
$eval_string = "'' + (typeof(window.KOBJ.buildDiv)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.get_host";
$eval_string = "'' + (typeof(window.KOBJ.get_host)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.close_notification";
$eval_string = "'' + (typeof(window.KOBJ.close_notification)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.getwithimage";
$eval_string = "'' + (typeof(window.KOBJ.getwithimage)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.require";
$eval_string = "'' + (typeof(window.KOBJ.require)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.reload";
$eval_string = "'' + (typeof(window.KOBJ.reload)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.eval";
$eval_string = "'' + (typeof(window.KOBJ.eval)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.registerDataSet";
$eval_string = "'' + (typeof(window.KOBJ.registerDataSet)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.registerClosure";
$eval_string = "'' + (typeof(window.KOBJ.registerClosure)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.clearExecutionDelay";
$eval_string = "'' + (typeof(window.KOBJ.clearExecutionDelay)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.percolate";
$eval_string = "'' + (typeof(window.KOBJ.percolate)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);



$description = "have defined a function called KOBJ.watchDOM";
$eval_string = "'' + (typeof(window.KOBJ.watchDOM)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.splitJSONRequest";
$eval_string = "'' + (typeof(window.KOBJ.splitJSONRequest)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.getJSONP";
$eval_string = "'' + (typeof(window.KOBJ.getJSONP)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.annotate_local_search_extractdata";
$eval_string = "'' + (typeof(window.KOBJ.annotate_local_search_extractdata)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.annotate_local_search_results";
$eval_string = "'' + (typeof(window.KOBJ.annotate_local_search_results)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);


$description = "have defined a function called KOBJ.annotate_search_extractdata";
$eval_string = "'' + (typeof(window.KOBJ.annotate_search_extractdata)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);



$description = "have defined a function called KOBJ.annotate_search_results";
$eval_string = "'' + (typeof(window.KOBJ.annotate_search_results)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.kGrowl";
$eval_string = "'' + (typeof(window.\$KOBJ.kGrowl)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

$description = "have defined a function called KOBJ.tabSlideOut";
$eval_string = "'' + (typeof(window.\$KOBJ('#atest').tabSlideOut)  != 'undefined')";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

foreach my $browser_platform (keys %$clients) {
	my $rstring = "a685x9";
	my $js = bookmarklet_js($sconfig,$rstring);
	my $c = $clients->{$browser_platform};
	# Seed the runtime
	$c->open_ok("http://www.google.com/");
	$c->set_speed("1000");
	$c->wait_for_page_to_load_ok("10000");
	$c->get_eval($js);
	$c->wait_for_condition("typeof(window.\$KOBJ) != 'undefined'",10000);
	foreach my $test_case (@runtime_testcases) {
		my $got = $c->get_eval($test_case->{'eval'});
		cmp_deeply($got,$test_case->{'expt'},$browser_platform . ": " . $test_case->{'desc'});
	}	
}

destroy_selenium_clients($clients);

1;