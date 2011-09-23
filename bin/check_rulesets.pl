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
use warnings;

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

use Cache::Memcached;
use APR::URI ();
use APR::Pool ();


use Kynetx::Parser ;
use Kynetx::Memcached;
use Kynetx::Repository;
use Kynetx::Configure;
use Kynetx::Test;

use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);


Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

# configure KNS
Kynetx::Configure::configure();
Kynetx::Memcached->init();

# global options
use vars qw/ %opt /;
my $opt_string = 'dv:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};


my @rids = qw/
1024dev
11
996337961
996337965
996337973
996337974
996337977
996337992
996337997
996338000
996338001
996338010
996338020
996338035
996338036
996338044
a143x3
a144x1
a144x2
a144x3
a163x1
a166x1
a166x8
a16x44
a16x45
a16x46
a173x1
a18x10
a18x3
a201x2
a218x3
a22x1
a22x4
a22x5
a25x6
a278x7
a314x3
a314x6
a325x4
a32x1
a32x2
a35x13
a37x6
a38x4
a41x10
a41x73
a41x78
a41x87
a50x3
a58x10
a58x12
a58x17
a58x18
a58x19
a58x2
a58x3
a58x4
a58x6
a58x7
a58x9
a60x16
a60x39
a60x52
a60x53
a60x58
a60x69
a60x9
a64x2
a66x1
a82x2
a8x13
a8x19
a8x20
a8x22
a8x31
a9x13
cs_test
cs_test_1
/;

		    
$Data::Dumper::Indent = 1;

foreach my $rid (@rids) {

  my $req_info = Kynetx::Test::gen_req_info($rid);


  my $tree = Kynetx::Repository::get_rules_from_repository($rid,$req_info);

  foreach my $rule (@{$tree->{'rules'}}) {
    my $cond = $rule->{'cond'} || {'type' => undef};
    if (ref $cond eq 'ARRAY') {
      $cond = $cond->[0];
    }
    if ($cond->{'type'} && $cond->{'type'} eq 'simple') {
#      print Dumper $cond;
      print "RID: $rid ",  Dumper $cond->{'predicate'} unless $cond->{'predicate'} eq 'truth';
    }

  }

}


1;



sub getkrl {


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

