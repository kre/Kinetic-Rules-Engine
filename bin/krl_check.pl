#!/usr/bin/perl -w

#use strict;
use lib qw(/web/lib/perl);

use strict;

use Kynetx::Parser ;

use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);


Log::Log4perl->easy_init($FATAL);


# global options
use vars qw/ %opt /;
my $opt_string = 'f:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};

my $filename = "";
$filename = $opt{'f'};
		    
$Data::Dumper::Indent = 1;

my $tree;
$tree = Kynetx::Parser::parse_ruleset(getkrl());

if(defined $tree->{'error'}) {
    warn "Parse error in $filename: \n" . $tree->{'error'};
}

1;



sub getkrl {

  open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
  local $/ = undef;
  my $krl = <KRL>;
  close KRL;
  return $krl;

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

