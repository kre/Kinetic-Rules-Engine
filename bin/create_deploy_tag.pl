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

use DateTime;
use Getopt::Std;

my $dt = DateTime->now;

my $ver = $dt->ymd('')."_prod_ver";


use vars qw/ %opt /;
my $opt_string = 'm:';
getopts( "$opt_string", \%opt ); 
die "must supply message with -m" unless $opt{'m'};

my $msg = $opt{"m"};

`git tag -a $ver -m $msg`
print "push to server with this command\n";
print "git push origin $ver", "\n";



1;
