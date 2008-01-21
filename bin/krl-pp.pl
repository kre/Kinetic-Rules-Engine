#!/usr/bin/perl -w

#use strict;
use lib qw(/web/lib/perl);

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

