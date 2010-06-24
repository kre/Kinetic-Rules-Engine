package Kynetx::Memcached;
# file: Kynetx/Memcached.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#
use strict;
use warnings;

# for memcache config values
use lib qw(
/web/etc
);

use Log::Log4perl qw(get_logger :levels);
#use LWP::Simple qw(get);
use LWP::UserAgent;
use Kynetx::Configure;
use Data::Dumper;

use constant DEFAULT_MEMCACHED_PORT => '11211';

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
init
get_memd
get_memcached_servers
get_remote_data
get_cached_file
check_cache
mset_cache
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

our $MEMD = 0;
our $MEMSERVERS = '127.0.0.1:' . DEFAULT_MEMCACHED_PORT;

sub init {
    my($class) = @_;

    my $logger = get_logger();

    $MEMSERVERS = Kynetx::Configure::get_config('MEMCACHE_SERVERS');

    $logger->debug("Initializing memcached: ", join(" ", @{ $MEMSERVERS }));

    # don't set compress threshold.  Compression uses MemGzip which doesn't
    # handle UTF chars correctly.
    $MEMD = new Cache::Memcached {
	'servers' => $MEMSERVERS,
	'debug' => 0
    };
    $MEMD->enable_compress(0);

}


sub get_memd {
    return $MEMD;
}

sub get_memcached_servers {
    return join(" ", $MEMSERVERS);
}

sub check_cache {
    my ($key) = @_;
    my $content;
    my $logger = get_logger();
    $logger->debug("cache key: ", $key);
    my $memd = get_memd();
    if ($memd) {
        $content = $memd->get($key);
    }
    if ($content) {
        $logger->debug("Using cached data for $key");
        return $content;
    }
}

sub mset_cache {
    my ($key,$content,$expire) = @_;
    my $logger = get_logger();
    if (not defined $expire || $expire < 1) {
        $expire = 10 * 60;
    }
    my $memd = get_memd();
    if ( $memd ) {
        $logger->debug("Caching $key for $expire seconds");
        my $set = $memd->set($key,$content,$expire);
    }
}


sub get_remote_data {
    my($url,$expire,$alt_key) = @_;
    my $key;

    $expire = 10 * 60 if (! $expire); # ten minutes

    my $logger = get_logger();
    my $memd = get_memd();

    if ($alt_key) {
        $key = $alt_key;
    }else {
        $key = $url;
    }

    my $content;
    if ($memd) {
        $content = check_cache($key) ;
	if ($content) {
	    $logger->debug("Using cached data for $url");
	    return $content;
	}
    }

    my $ua = LWP::UserAgent->new;
    $ua->agent("Kynetx Rule Engine/1.0");

    my $req = HTTP::Request->new(GET => $url);
    my $res = $ua->request($req);

    if($res->is_success) {
	$content = $res->decoded_content;
    } else {
	$content = '';
	$logger->debug("Error retrieving $url: " . $res->status_line . "\n");
    }

    if($memd && $res->is_success) {
	$logger->debug("Caching data for $url for $expire seconds");
	mset_cache($key,$content,$expire);
    }

    return $content;

}

# FIXME: probably ought to refactor this and previous function to use a common core
sub get_cached_file {
    my($filepath,$expire) = @_;
    my $logger = get_logger();
    $logger->trace("get file: ", $filepath);

    $expire = 60 * 60 if (! $expire); #   one hour

    my $memd = get_memd();

    my $key = $filepath;

    my $content;
    if ($memd) {
        $content = $memd->get($key) ;
	if ($content) {
	    $logger->debug("Using cached data for $filepath");
	    return $content;
	}
    }

    $content = read_file_contents($filepath);

    if($memd) {
	$logger->debug("Caching data for $filepath");
	$memd->set($key,$content,$expire);
    }

    return $content;

}

sub read_file_contents {

    my ($filepath) = @_;

    open(FOO, "< $filepath") ;
# || die "Can't open file $filepath: $!\n";

    # read it all at once
    local $/ = undef;
    my $contents = <FOO>;

    close FOO;
    return $contents;

}


1;

