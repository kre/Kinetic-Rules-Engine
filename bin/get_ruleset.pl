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
use Kynetx::Util;

use JSON::XS;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Time::HiRes qw/tv_interval gettimeofday/;

Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

# configure KNS
Kynetx::Configure::configure();
Kynetx::Memcached->init();

Kynetx::Util::config_logging();

# global options
use vars qw/ %opt /;
my $opt_string = 'r:s:ht?';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};


my $rid = $opt{'r'};

my $section = $opt{'s'};

my $req_info = Kynetx::Test::gen_req_info($rid);

my $t0 = [gettimeofday];
#my $tree = Kynetx::Repository::get_rules_from_repository($rid,$req_info);
my $tree = Kynetx::Rules::get_rule_set($req_info);
$tree = $tree->{$section} if $section;
my $t1 = tv_interval($t0, [gettimeofday]);

print Dumper $tree;
print "\nElapsed retrieval time: $t1\n" if $opt{'t'};

1;




sub usage {

    print STDERR <<EOF;

usage:  

   get_ruleset.pl -r rid

Gets ruleset like it's the engine.  That is, it will get the cached ruleset if 
it is in the cache or retrieve it and optimize it (and cache) it if not.

Options are:

   -r : rid to retrieve
   -s : section of ruleset to return
   -t : print elapsed retrieval time as well


EOF

exit;

}

