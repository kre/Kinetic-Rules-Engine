#!/usr/bin/perl -w

#use strict;
use lib qw(/web/lib/perl);
use warnings;

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
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Time::HiRes qw/tv_interval gettimeofday/;

Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

# configure KNS
Kynetx::Configure::configure();
Kynetx::Memcached->init();

# global options
use vars qw/ %opt /;
my $opt_string = 'r:ht?';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};


my $rid = $opt{'r'};

my $req_info = Kynetx::Test::gen_req_info($rid);

my $t0 = [gettimeofday];
my $tree = Kynetx::Repository::get_rules_from_repository($rid,$req_info);
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
   -t : print elapsed retrieval time as well


EOF

exit;

}

