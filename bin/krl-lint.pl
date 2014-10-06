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

use Cache::Memcached;


use Kynetx::Test qw/:all/;
use Kynetx::FakeReq;
use Kynetx::Parser ;
use Kynetx::PrettyPrinter qw/:all/ ;
use Kynetx::Memcached qw/:all/;
use Kynetx::Environments qw/:all/ ;
use Kynetx::Modules qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Rids qw/:all/;
use Kynetx::Rules qw/:all/ ;
use Kynetx::JavaScript qw/:all/;
use Kynetx::JavaScript::AST qw/:all/;
use Kynetx::Modules::System qw/:all/;
use Kynetx::Modules::RuleEnv qw/:all/;


use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);

Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);


# global options
use vars qw/ %opt /;
my $opt_string = 'hf:';
getopts( $opt_string, \%opt ); # or &usage();
&usage() if $opt{'h'};
&usage unless $opt{'f'};

my $filename = "";
$filename = $opt{'f'};


$Data::Dumper::Indent = 1;

my $logger = get_logger();

<<<<<<< HEAD
=======
#
# check for undefined vars
# check for redefined vars
# 

>>>>>>> 0e7d9a0df758d9ca1358bf609bc9ef0e12701785

my $tree;

$tree = Kynetx::Parser::parse_ruleset(get_krl());


my $ruleset = Kynetx::Rules::optimize_ruleset($tree);

if(defined $tree->{'error'}) {
    warn "Parse error in $filename: \n" , join("\n ", @{$tree->{'error'}});
} else {
#    print Dumper($tree), "\n";
} 

my $memd = get_memd();
my $rid = $ruleset->{"ruleset_name"};
my $r = Kynetx::Test::configure();
my $req_info = Kynetx::Test::gen_req_info($rid);
my $session = Kynetx::Test::gen_session($r, $rid);

# rid to raise errors to
$req_info->{'errorsto'} = $ruleset->{'meta'}->{'errors'};

my $eid = int(rand(999999));
my $rule_env = Kynetx::Rules::mk_initial_env();
my $env_stash = {};
my $ast = Kynetx::JavaScript::AST->new($eid);


$rule_env = Kynetx::Rules::get_rule_env( $req_info, $ruleset, $session, $ast, $env_stash );

print  Dumper(sub {$rule_env}) ;

print  Dumper($req_info) ;	    

1;



sub get_krl {

  open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
  local $/ = undef;
  my $krl = <KRL>;
  close KRL;
  return $krl;

}


sub usage {

    print STDERR <<EOF;

usage:  

   krl-lint.pl -f filename [-l] [-j] [-r] [-c]

krl-lint.pl warns of problems in KRL programs. 

Options are:

   -t : print timing information


EOF

exit;

}

