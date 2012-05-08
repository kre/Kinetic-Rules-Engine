#!/usr/bin/perl -w 
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
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

my $numtests = 11;
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
	
	$content = get_remote_data("http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt",10);
	Kynetx::Memcached::mset_cache('test1', $content,1);
	my $c1 = Kynetx::Util::str_out($content);
	my $c2 = $memd->get("test1");
	is($c2,$c1,'Stored in memcache as chars');
	
	my $c3 = Kynetx::Memcached::check_cache('test1');
	is($c3,$content,"Perl byte representation");
	
	
	contains_string(
		$c1,
		'⡌⠁⠧⠑ ⠼⠁⠒  ⡍⠜⠇⠑⠹⠰⠎ ⡣⠕⠌',
		'Check get_remote_data for UTF-8 correctness'
	);

    $memd->delete("test1");

    my $rid = 'cs_test';
    ok(!Kynetx::Memcached::is_parsing($memd, $rid), "Not parsing now");
    
    Kynetx::Memcached::set_parsing_flag($memd, $rid);

    ok(Kynetx::Memcached::is_parsing($memd, $rid), "Parsing now");
    
    Kynetx::Memcached::clr_parsing_flag($memd, $rid);

    ok(!Kynetx::Memcached::is_parsing($memd, $rid), "Not parsing now");
    
}

1;


