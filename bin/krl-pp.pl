#!/usr/bin/perl -w

#use strict;
use lib qw(/web/lib/perl);

use strict;

use Kynetx::PrettyPrinter qw/:all/;
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
# &usage() if $opt{'h'};

my $filename = "";
$filename = $opt{'f'};
		    
my $tree = parse_ruleset(getkrl());

print pp($tree);

1;



sub getkrl {

  open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
  local $/ = undef;
  my $krl = <KRL>;
  close KRL;
  return $krl;

}

