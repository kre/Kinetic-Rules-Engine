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

use Kynetx::Parser ;

use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);


Log::Log4perl->easy_init($FATAL);


# global options
use vars qw/ %opt /;
my $opt_string = 'f:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};

my $filename = "";
$filename = $opt{'f'};
		    
$Data::Dumper::Indent = 1;

my $tree;
$tree = Kynetx::Parser::parse_ruleset(getkrl());

if(defined $tree->{'error'}) {
    warn "Parse error in $filename: \n" . $tree->{'error'};
}

1;



sub getkrl {

  open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
  local $/ = undef;
  my $krl = <KRL>;
  close KRL;
  return $krl;

}


sub usage {

    print STDERR <<EOF;

usage:  

   krl-parser.pl -f filename [-l] [-j]

krl_check.pl parses a ruleset and returns the errors, if any.  If there are no errors
krl_check.pl returns nothing.

Options are:

   -f : filename to parse


EOF

exit;

}

