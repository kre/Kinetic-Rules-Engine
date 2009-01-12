#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use Cache::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Memcached qw/:all/;

my $logger = get_logger();

my $numtests = 3;
plan tests => $numtests;

my $config_file = "/web/etc/memcache_ips.pm";

ok(-f $config_file, "Does the config file exist?");


SKIP: {
    skip "No config file available", $numtests-1 if (! -f $config_file);

    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my $memd = get_memd();

    my $now = time();

    $memd->set("test1", $now);

    is($memd->get("test1"), $now, "Did it get stored?");

    $memd->delete("test1");

    is($memd->get("test1"), undef, "Did it get deleted?");
}

1;


