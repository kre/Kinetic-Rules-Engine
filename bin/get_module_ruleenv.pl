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
use warnings;

use strict;

use Cache::Memcached;
use APR::URI ();
use APR::Pool ();


use Kynetx::Memcached qw(:all);
use Kynetx::Configure;
use Kynetx::Test;
use Kynetx::Util;
use Kynetx::Modules::RuleEnv;

use JSON::XS;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;


Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

# configure KNS
Kynetx::Configure::configure();
Kynetx::Memcached->init();

Kynetx::Util::config_logging();

# global options
use vars qw/ %opt /;
my $opt_string = 's:jh?';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};


my $module_sig = $opt{'s'};

my $req_info = Kynetx::Test::gen_req_info("cs_test");


  my $memd = get_memd();

  my $module_cache = Kynetx::Modules::RuleEnv::get_module_cache($module_sig, $memd);
  my $module_rule_env = $module_cache->{Kynetx::Modules::RuleEnv::get_re_key($module_sig)};
  my $provided = $module_cache->{Kynetx::Modules::RuleEnv::get_pr_key($module_sig)} || {};
  my $js = $module_cache->{Kynetx::Modules::RuleEnv::get_js_key($module_sig)} || '';

print Dumper $module_rule_env;
print "Provided ", join(", ", keys %{ $provided }), "\n";
print $js if $opt{'j'};


1;




sub usage {

    print STDERR <<EOF;

usage:  

   $0 -s signature 

Gets ruleset like it's the engine.  That is, it will get the cached ruleset if 
it is in the cache or retrieve it and optimize it (and cache) it if not.

Options are:

   -j : print cached JavaScript


EOF

exit;

}

