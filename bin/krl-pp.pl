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
#use strict;
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

use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Parser qw/:all/;


use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);



Log::Log4perl->easy_init($DEBUG);


# global options
use vars qw/ %opt /;
my $opt_string = 'hf:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};

my $filename = "";
$filename = $opt{'f'};


my $in = getin();    
print jsonToKrl($in);


1;



sub getin {

  open(IN, "< $filename") || die "Can't open file $filename: $!\n";
  local $/ = undef;
  my $in = <IN>;
  close IN;
  return $in;

}

sub usage {

    print STDERR <<EOF;

usage:  

    krl-pp.pl -f filename

krl-pp.pl takes a JSON representation of a KRL ruleset as input and 
prints the KRL representation to the standard output.  


EOF

exit;

}

