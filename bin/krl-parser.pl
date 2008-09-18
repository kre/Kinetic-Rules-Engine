#!/usr/bin/perl -w

#use strict;
use lib qw(/web/lib/perl);

use strict;

use Kynetx::Parser ;
use Kynetx::ParserOld ;

use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);



Log::Log4perl->easy_init($DEBUG);


# global options
use vars qw/ %opt /;
my $opt_string = 'lhjof:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};

my $lex_only = 0;
$lex_only = $opt{'l'} if $opt{'l'};

my $old_parser = 0;
$old_parser = $opt{'o'} if $opt{'o'};

my $output_json = 0;
$output_json = $opt{'j'} if $opt{'j'};

my $filename = "";
$filename = $opt{'f'};
		    
if($lex_only) {
    if($old_parser) {
	Kynetx::Parser::dump_lex(getkrl());
    } else {
	print Kynetx::ParserNG::remove_comments(getkrl());
    }
} else {

    $Data::Dumper::Indent = 1;

    my $tree;
    if($old_parser) {
	$tree = Kynetx::ParserOld::parse_ruleset(getkrl());
    } else {
	$tree = Kynetx::Parser::parse_ruleset(getkrl());
    }

    if(defined $tree->{'error'}) {
	warn "Parse error in $filename: \n" . $tree->{'error'};
    } else {
	if ($output_json) {
	    print encode_json($tree), "\n";
	} else {
	    print Dumper($tree), "\n";
	}
    } 
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

krl-parser.pl takes a text representation of a KRL ruleset as input and 
prints the corresponding Perl abstract syntax tree to the STDOUT.  

Options are:

   -l : only lex the file, do not parse.  Lexical results are printed.

   -j : return the JSON representation instead of Perl.


EOF

exit;

}

