#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use Cache::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Configure;

my $logger = get_logger();

my $numtests = 5;
plan tests => $numtests;

my $config_file = "/web/etc/kns_config.yml";

ok(-f $config_file, "Does the config file exist?");

Kynetx::Configure::configure();

SKIP: {
    skip "No config file available", $numtests-1 if (! -f $config_file);

    Kynetx::Memcached->init();

    my $memd = get_memd();

    my $now = time();

    $memd->set("test1", $now);

    is($memd->get("test1"), $now, "Did it get stored?");

    $memd->delete("test1");

    is($memd->get("test1"), undef, "Did it get deleted?");


    my $content = get_remote_data('http://twitter.com/statuses/public_timeline.json',1);
    contains_string(
	$content,
	'"text":',
	'Get public timeline');
    
    $content = get_remote_data('https://twitter.com/statuses/public_timeline.json',1);
    contains_string(
	$content,
	'"text":',
	'Get public timeline with HTTPS');
    
}

1;


