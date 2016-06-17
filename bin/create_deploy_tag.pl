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

my $ver = $dt->ymd('').sprintf("%.2d",$dt->hour()).sprintf("%.2d",$dt->min())."_prod_ver";


use vars qw/ %opt /;
my $opt_string = 'm:ns?h';
getopts( "$opt_string", \%opt ); 
&usage() if $opt{'h'} || $opt{'?'};

my $msg = $opt{"m"};
my $show_changes = $opt{"s"};

if($show_changes) {

  my $tags = `git tag -l "*_prod_ver" |tail -2`;
  my $tag_expr =  join("..", split(/\n/,$tags));
  print "Changes between $tag_expr\n";
  print `git log --pretty=oneline $tag_expr`;
    

} else {

    die "must supply message with -m" unless $opt{'m'};
    `git tag -a $ver -m "$msg"` ;
    if ($opt{"n"}) {
	print "push to server with this command\n";
	print "git push origin $ver", "\n";
    } else {
	`git push origin $ver` 
    }
}

1;

sub usage {
    print STDERR <<EOF;

usage:  

   create_deploy_tag.pl [-?sm]

Create deploy tags for production

Options:

   -m       : message with tag
   -n       : don't push to origin
   -s       : show changes between tags (don't create tag)


EOF

exit;
}

1;
