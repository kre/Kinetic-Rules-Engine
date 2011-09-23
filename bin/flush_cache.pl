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
use Cache::Memcached;
use Log::Log4perl qw(get_logger :levels);


use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw/:all/;


# configure KNS
Kynetx::Configure::configure();

Log::Log4perl->easy_init($WARN);

# global options
use vars qw/ %opt /;
my $opt_string = 'h?k:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $key = $opt{'k'};

die "You must supply a key\n" unless $key;


print "flushing cache for key $key\n";

my $logger = get_logger();

Kynetx::Memcached->init();
my $memd = get_memd();
$memd->delete($key);


1;

sub usage {
    print STDERR <<EOF;

usage:  

   flush_cache.pl [-k]

Flush the key given by k to 

Options are:

  -k	: Key to flush

Examples:

  flush_cache.pl -k http://www.example.com/data.json

  flush_cache.pl -k ruleset:kntx_foo

EOF

exit;


}

