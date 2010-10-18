#!/usr/bin/perl -w

use lib qw(/web/lib/perl);

use strict;

use Getopt::Std;
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Memcached qw(:all);
use Cache::Memcached;
use Kynetx::Configure qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;

# configure KNS
Kynetx::Configure::configure();

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

# global options

my $memd = new Cache::Memcached {
   'servers' => Kynetx::Configure::get_config("MEMCACHE_SERVERS"),
   'debug' => 0,
   'compress_threshold' => 10_000,
};
use vars qw/ %opt /;
my $opt_string = 'h?k:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $key = $opt{'k'};

die "You must supply a ruleset key [ruleset:<prod|dev>:<rid>]\n" unless $key;

my $result = $memd->get($key);

print Dumper($result);

1;

sub usage {
    print STDERR <<EOF;

usage:  

   mcpeek.pl -k session_id

Peek at a cached ruleset.

Options are:

  -k    : Ruleset key to dump...

Examples:

  mcpeek.pl -k ruleset:prod:a22x2

EOF

exit;

}