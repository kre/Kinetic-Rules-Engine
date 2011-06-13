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

use Log::Log4perl::Level;
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($WARN);
Log::Log4perl->easy_init($DEBUG);

my $logger = get_logger();

use Kynetx::Configure qw/:all/;
use constant CMODULE => 'SELENIUM';

my $selenium_config_file = "/web/lib/perl/runtime_test/config/perl_selenium.yml";
my @RUN_MODES = ( "development", "qa", "production" );

# New reference uses the default YML file from Configure.pm
Kynetx::Configure::configure();

# Run mode determines what the next level of verification on config
# variables beyond existance
# Valid options are (production|development)
my $runmode = Kynetx::Configure::get_config('RUN_MODE');

$runmode = 'qa';

BAIL_OUT('Config variable RUN_MODE must be defined in the kns_config')
  unless ($runmode);

my $found = grep ( /^$runmode$/, @RUN_MODES );

BAIL_OUT("Run mode configuration variable ($runmode) is undefined")
  unless ($found);
  
my $selenium_config = Kynetx::Configure::get_config("SELENIUM");

BAIL_OUT('Config variable SELENIUM must be defined in the kns_config')
  unless ($selenium_config);


$logger->info("Test Mode: $runmode");

my $sconfig = make_selenium_config($runmode);
my $clients = init_selenium_clients();


my ($description,$eval_string,$expected,$runtime_js,$js,$search_url,$bm);
my (@runtime_testcases,@search_annotation_testcases);

sub init_selenium_clients {
	my $client_config = Kynetx::Configure::get_config("selenium_clients",CMODULE);
	foreach my $client (keys %$client_config) {
		$logger->debug("Client: $client");
		my $host = $client_config->{$client}->{'host'};
		my $port = $client_config->{$client}->{'port'};
		my $browser = $client_config->{$client}->{'browser'};
		my $sel = Test::WWW::Selenium->new( host => $host, 
	                                    port => $port, 
	                                    browser => $browser,
	                                    browser_url => 'http://www.kynetx.com' );
		$logger->debug(" host: $host");
		$sel->open();
		$sel->set_speed("1000");	
		$clients->{$client} = $sel;
	}
	return $clients;
	
}

sub destroy_selenium_clients {
	my ($clist) = @_;
	foreach my $browser_platform (keys %$clist) {
		my $c = $clist->{$browser_platform};
		$c->stop();
	}
}

sub make_selenium_config {
	my ($runmode) = @_;
	$runmode = Kynetx::Configure::get_config('RUN_MODE') unless (defined $runmode);
	my $init_host = Kynetx::Configure::get_config('INIT_HOST', $runmode);
	my $eval_host = Kynetx::Configure::get_config('EVAL_HOST', $runmode);
	my $krl_host  = Kynetx::Configure::get_config('KRL_HOST', $runmode);
	my $krl_port  = Kynetx::Configure::get_config('KRL_PORT', $runmode) || '80';
	my $cookie_domain = Kynetx::Configure::get_config('COOKIE_DOMAIN', $runmode);
	my $runtime = "http://$init_host/js/shared/kobj-static.js";
	$logger->info("INIT_HOST: $init_host");
	$logger->info("EVAL_HOST: $eval_host");
	$logger->info("KRL_HOST: $krl_host");
	$logger->info("KRL_PORT: $krl_port");
	$logger->info("COOKIE_DOMAIN: $cookie_domain");
	return {
		'init' => $init_host,
		'eval' => $eval_host,
		'krlh' => $krl_host,
		'krlp' => $krl_port,
		'runt' => $runtime
	};
}

sub add_runtime_testcase {
	my ($description, $eval_string,$expected) = @_;
	push(@runtime_testcases, {
		'desc' => $description,
		'eval' => $eval_string,
		'expt' => $expected
	});
}

sub add_search_testcase {
	my ($description, $search_url, $js, $expected) = @_;
	push(@search_annotation_testcases, {
		'desc' => $description,
		'surl' => $search_url,
		'expt' => $expected,
		'js'   => $js
	});
}

sub bookmarklet_js {
	my ($config,$ridstring) = @_;
	my $ehost = $config->{'eval'};
	my $cbhost = $ehost;
	my $ihost = $config->{'init'};
	my $runtime = $config->{'runt'};	
	my $js = <<_JS_;
var d = window.document;var r = d.createElement('script'); r.text = 'KOBJ_config={"rids":["$ridstring"],init:{"eval_host":"$ehost","init_host":"$ihost"}} '; var body = d.getElementsByTagName('body')[0];body.appendChild(r);var q=d.createElement('script');q.src='$runtime';body.appendChild(q);
_JS_
	return $js;
}





# Runtime Test Cases
## functions function
$description = "have albility to get application from runtime";
$eval_string = "window.KOBJ.get_application('a685x9') != null";
$expected = "true";
add_runtime_testcase($description,$eval_string,$expected);

#goto ENDY;


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

$description = "Annotate Lenny's Subs in Google";
$search_url = "http://www.google.com/search?q=lennys+subs";
$expected = '//img[contains(@src,"https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png")]';
$bm = bookmarklet_js($sconfig,'a279x1');
add_search_testcase($description, $search_url, $bm, $expected);

$description = "Annotate Lenny's Subs in Yahoo";
$search_url = "http://search.yahoo.com/search?p=lennys+subs";
$expected = '//img[contains(@src,"https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png")]';
add_search_testcase($description, $search_url, $bm, $expected);

$description = "Annotate Lenny's Subs in Bing";
$search_url = "http://www.bing.com/search?q=lennys+subs";
$expected = '//img[contains(@src,"https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png")]';
add_search_testcase($description, $search_url, $bm, $expected);

#($description, $search_url, $js, $expected)
#//img[contains(@src,'https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png')]
foreach my $browser_platform (keys %$clients) {
	my $c = $clients->{$browser_platform};
	foreach my $test_case (@search_annotation_testcases) {
		$c->open_ok($test_case->{'surl'});
		$c->set_speed("1000");
		$c->wait_for_page_to_load_ok("10000");
		$c->get_eval($test_case->{'js'});
		my $got = $c->wait_for_element_present($test_case->{'expt'});
		cmp_deeply($got,"OK",$browser_platform . ": " . $test_case->{'desc'});
	}
}

ENDY:

foreach my $browser_platform (keys %$clients) {
#my $xjs = <<_JS_;
#var d = window.document;var r = d.createElement('script'); r.text = 'KOBJ_config={"rids":["a685x9"],init:{"eval_host":"$eval_host","init_host":"$init_host"}} '; var body = d.getElementsByTagName('body')[0];body.appendChild(r);var q=d.createElement('script');q.src='http://qa.kobj.net/js/shared/kobj-static.js';body.appendChild(q);
#_JS_
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

done_testing();
1;