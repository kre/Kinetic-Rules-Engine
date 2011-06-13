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


sub add_search_testcase {
	my ($description, $search_url, $js, $expected) = @_;
	push(@search_annotation_testcases, {
		'desc' => $description,
		'surl' => $search_url,
		'expt' => $expected,
		'js'   => $js
	});
}

# Search Annotation (Axiom a279x1)
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



destroy_selenium_clients($clients);

1;