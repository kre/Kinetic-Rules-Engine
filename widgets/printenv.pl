#!/usr/local/bin/perl -w
##
##  printenv -- demo CGI program which just prints its environment
##

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

use lib qw(/web/lib/perl);

# header
print "Content-type: text/plain; charset=iso-8859-1;\n";
print "Flipper: hello world!; \n\n";

# body
foreach my $var (sort(keys(%ENV))) {
    my $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    print "${var}=\"${val}\"\n";
}

my $tmpStr;
read( STDIN, $tmpStr, $ENV{ "CONTENT_LENGTH" } );
if ($ENV{'CONTENT_TYPE'} eq 'application/x-www-form-urlencoded') {
  my @parts = split( /\&/, $tmpStr );
  foreach my $part (@parts) {
    my ( $name, $value ) = split( /\=/, $part );
    $value =~ ( s/%23/\#/g );
    $value =~ ( s/%2F/\//g );
    print "$name => $value\n";
  }

} else {
   print $tmpStr, "\n";
}
