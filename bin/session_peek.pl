#!/usr/bin/perl -w

use lib qw(/web/lib/perl);

use strict;

use Getopt::Std;
use Cache::Memcached;
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Memcached qw(:all);
use Apache::Session::Memcached;

use DateTime;
use Kynetx::Configure qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::FakeReq qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;

# configure KNS
Kynetx::Configure::configure();


# get a session
my $r = new Kynetx::FakeReq();



Log::Log4perl->easy_init($WARN);
Log::Log4perl->easy_init($DEBUG);

# global options
use vars qw/ %opt /;
my $opt_string = 'h?k:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $key = $opt{'k'};

die "You must supply a session ID\n" unless $key;

my $session = process_session($r, $key);

print Dumper($session);


1;

sub usage {
    print STDERR <<EOF;

usage:  

   session_peek.pl -k session_id

Peek at the session for session ID given by the flag k.

Options are:

  -k	: Session ID to dump...

Examples:

  session_peek.pl -k c8bb32a812538354a853b9aca23f6acf

EOF

exit;


}

