#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;

# global options
use vars qw/ %opt /;
my $opt_string = 'clhrjotf:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};
&usage unless $opt{'f'};

my ($filenames, $current_eid);

my $log_file = 'detail_log';
$log_file = $opt{'f'};

unlink glob "'./*.split'" if $opt{"d"};
 
if (open(my $fh, $log_file)) {
    while (my $row = <$fh>) {
	chomp $row;
	my ($time, $eid, $type, $message) = split(/ /, $row, 4);

	if (defined $time && $time =~ m/\d[4]|\d[5]/) {

	    if (    defined $eid
		 && ! defined $filenames->{$eid}
	       ) {
		my $filename = $time. "-". $eid. ".split";
		open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
		$filenames->{$eid} = $fh;
	    } 
	    $current_eid = $eid;
	
	}
	print {$filenames->{$current_eid}}  $row . "\n";

    }
} else {
    warn "Could not open file '$log_file' $!";
}

foreach my $fh (values %{$filenames}) {
    close $fh;
}

sub usage {

    print STDERR <<EOF;

usage:  

   split_detail_log.pl -f filename 

Splits a detail log file by EID. 

Produces a file for each EID in the given detail log with the first time prepended so that you can (usually) take the first file in a sorted list as the earliest EID. This doesn't work if the UNIX timestamp being used by the web server wraps around zero. 

Warning: running this on a large detail log can result in many split files. 

Options:

  -d  : delete files with extention .split before beginning


EOF

exit;

}

