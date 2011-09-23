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
use Apache::Session::Memcached;

use DateTime;
use Kynetx::Configure qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::FakeReq qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;

# configure KNS
Kynetx::Configure::configure();


# get a session
my $r = new Kynetx::FakeReq();



Log::Log4perl->easy_init($WARN);
#Log::Log4perl->easy_init($DEBUG);

# global options
use vars qw/ %opt /;
my $opt_string = 'h?k:r:v:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $key = $opt{'k'};

die "You must supply a session ID\n" unless $key;

my $session = process_session($r, $key);


if ($opt{'v'} && $opt{'r'}) {
  print Dumper(session_get($opt{'r'}, $session, $opt{'v'}));
} else {
  print Dumper($session);
}


1;

sub usage {
    print STDERR <<EOF;

usage:  

   session_peek.pl -k session_id

Peek at the session for session ID given by the flag k.

Options are:

  -k	: Session ID to dump...

Examples:

  session_peek.pl -k c8bb32a812538354a853b9aca23f6acf

EOF

exit;


}

