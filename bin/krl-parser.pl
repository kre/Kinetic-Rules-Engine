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
#use strict;
use lib qw(/web/lib/perl);

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
use strict;

use Kynetx::Parser ;
use Kynetx::PrettyPrinter qw/:all/ ;
#use Kynetx::Rules qw/:all/ ;

use JSON::XS;
use Data::Dumper;
use Getopt::Std;

use Log::Log4perl qw(get_logger :levels);


use Time::HiRes qw/tv_interval gettimeofday/;


Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);


# global options
use vars qw/ %opt /;
my $opt_string = 'clhrjotf:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};
&usage unless $opt{'f'};

my $lex_only = 0;
$lex_only = $opt{'l'} if $opt{'l'};

my $output_json = 0;
$output_json = $opt{'j'} if $opt{'j'};

my $roundtrip = 0;
$roundtrip = $opt{'r'} if $opt{'r'};

my $optimize = 0;
$optimize = $opt{'o'} if $opt{'o'};

my $remove_comments = 0;
$remove_comments = $opt{'c'} if $opt{'c'};

my $print_time = 0;
$print_time = $opt{'t'} if $opt{'t'};

my $filename = "";
$filename = $opt{'f'};


my ($t0, $t1);

$t0 = [gettimeofday];
		    
if($lex_only) {
    print Kynetx::Parser::remove_comments(getkrl());
    $t1 = tv_interval($t0, [gettimeofday]);
} elsif ($remove_comments) {
    print Kynetx::Parser::remove_comments(getkrl());
    $t1 = tv_interval($t0, [gettimeofday]);
} else {

    $Data::Dumper::Indent = 1;

    my $tree;


    $tree = Kynetx::Parser::parse_ruleset(getkrl());
    $t1 = tv_interval($t0, [gettimeofday]);

    if ($optimize) {
      $tree = Kynetx::Rules::optimize_rules($tree);
    }

    if(defined $tree->{'error'}) {
	warn "Parse error in $filename: \n" . $tree->{'error'};
    } else {
	if ($output_json) {
	    print encode_json($tree), "\n";
	} elsif ($roundtrip) {
	    print pp($tree), "\n";
	} else {
	    print Dumper($tree), "\n";
	}
    } 
}

print "Elapsed time: $t1\n" if $print_time;

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

   krl-parser.pl -f filename [-l] [-j] [-r] [-c]

krl-parser.pl takes a text representation of a KRL ruleset as input and 
prints the corresponding Perl abstract syntax tree to the STDOUT.  

Options are:

   -l : only lex the file, do not parse.  Lexical results are printed.

   -j : return the JSON representation instead of Perl.

   -r : return the KRL that the pretty printer returns for the parsed file

   -c : remove comments

   -t : print timing information


EOF

exit;

}

