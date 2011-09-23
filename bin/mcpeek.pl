#!/usr/bin/perl -w

use lib qw(/web/lib/perl);

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

use Getopt::Std;
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Memcached qw(:all);
use Cache::Memcached;
use Kynetx::Configure qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;

# configure KNS
Kynetx::Configure::configure();

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

# global options

my $memd = new Cache::Memcached {
   'servers' => Kynetx::Configure::get_config("MEMCACHE_SERVERS"),
   'debug' => 0,
   'compress_threshold' => 10_000,
};
use vars qw/ %opt /;
my $opt_string = 'h?k:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $key = $opt{'k'};

die "You must supply a ruleset key [ruleset:<prod|dev>:<rid>]\n" unless $key;

my $result = $memd->get($key);

print Dumper($result);

1;

sub usage {
    print STDERR <<EOF;

usage:  

   mcpeek.pl -k session_id

Peek at a cached ruleset.

Options are:

  -k    : Ruleset key to dump...

Examples:

  mcpeek.pl -k ruleset:prod:a22x2

EOF

exit;

}