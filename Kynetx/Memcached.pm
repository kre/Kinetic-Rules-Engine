package Kynetx::Memcached;
# file: Kynetx/Memcached.pm
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
use strict;
#use warnings;
no warnings qw(uninitialized numeric);

use utf8;

# for memcache config values
use lib qw(
/web/etc
);

use Log::Log4perl qw(get_logger :levels);
#use LWP::Simple qw(get);
use LWP::UserAgent;
use Kynetx::Configure;
use Kynetx::Util qw(str_in str_out);
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
flush_cache
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

our $MEMD = 0;
our $MEMSERVERS = '127.0.0.1:' . DEFAULT_MEMCACHED_PORT;

sub init {
    my($class) = @_;

    my $logger = get_logger();
    my $parent = (caller(1))[3];
    
    return if ($MEMD);
    
    $MEMSERVERS = Kynetx::Configure::get_config('MEMCACHE_SERVERS');

    $logger->debug("Initializing memcached ($parent): ", join(" ", @{ $MEMSERVERS }));

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

# this could be made more efficient by using add to check
# but the result is used in MondoDB.pm, so we'd have to change that. 
sub check_cache {
    my ($key) = @_;
    my $content;
    my $logger = get_logger();
    $logger->trace("cache key: ", $key);
    my $parent = (caller(1))[3];
    my $memd = get_memd();
    if ($memd) {
        $content = $memd->get($key);
    }
    if ($content) {
        #$logger->trace("-$parent- Using cached data for $key");
        if (ref $content eq "") {
        	return Kynetx::Util::str_in($content);
        } else {
        	return $content;
        }
        
    }
}

sub mset_cache {
    my ($key,$content,$expire) = @_;
    my $logger = get_logger();
    if (! defined $expire || $expire < 1) {
        $expire = 10 * 60;
    }
    my $memd = get_memd();
    my $parent = (caller(1))[3];
    if ( $memd ) {
        if (ref $content eq "") {
        	my $safe = Kynetx::Util::str_out($content);
        	$memd->set($key,$safe,$expire);
        } else {
        	$memd->set($key,$content,$expire);
        }
        
    }
}

sub flush_cache {
    my ($key) = @_;
    my $logger = get_logger();
    my $memd = get_memd();
    $memd->delete($key);
    $logger->trace("Flushed ($key) from cache");
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
    $logger->trace("Result: ", sub {Dumper($res)});

    if($res->is_success) {
		my $raw = $res->content;
		$content = Kynetx::Util::str_in($raw);
    } else {
	$content = '';
	$logger->debug("Error retrieving $url: " . $res->status_line . "\n");
    }

    if($memd && $res->is_success) {
	$logger->trace("Caching data for $url for $expire seconds");
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
	    $logger->trace("Using cached data for $filepath");
	    return $content;
	}
    }

    $content = read_file_contents($filepath);

    if($memd) {
	$logger->trace("Caching data for $filepath");
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

#-------------------------------------------------------------
# use memcache as a semaphore for parsing

sub set_parsing_flag {
  my $memd = shift;
  my $rid = shift;
  my $time = shift || 60; # defaults to 60 seconds
  $memd->set("parsing:$rid", 1, $time);
}

sub clr_parsing_flag {
  my $memd = shift;
  my $rid = shift;
  $memd->set("parsing:$rid", 0);
}

sub is_parsing {
  my $memd = shift;
  my $rid = shift;
  return $memd->get("parsing:$rid");
}

1;

