#!/usr/bin/perl -w

use lib qw(/web/lib/perl);

use strict;

use Getopt::Std;
use Cache::Memcached;
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw/:all/;


# configure KNS
Kynetx::Configure::configure();

Log::Log4perl->easy_init($WARN);

# global options
use vars qw/ %opt /;
my $opt_string = 'h?k:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $key = $opt{'k'};

die "You must supply a key\n" unless $key;


print "flushing cache for key $key\n";

my $logger = get_logger();

Kynetx::Memcached->init();
my $memd = get_memd();
$memd->delete($key);


1;

sub usage {
    print STDERR <<EOF;

usage:  

   flush_cache.pl [-k]

Flush the key given by k to 

Options are:

  -k	: Key to flush

Examples:

  flush_cache.pl -k http://www.example.com/data.json

  flush_cache.pl -k ruleset:kntx_foo

EOF

exit;


}

