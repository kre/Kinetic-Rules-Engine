package Kynetx::Test;
# file: Kynetx/Test.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
getkrl
trim
nows
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub getkrl {
    my $filename = shift;

    open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
    my $first_line = <KRL>;
    local $/ = undef;
    my $krl = <KRL>;
    close KRL;
    if ($first_line =~ m%^\s*//.*%) {
	return ($first_line,$krl);
    } else {
	return ("No comment", $first_line . $krl);
    }

}

# Perl trim function to remove whitespace from the start and end of the string
sub trim {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub nows {
    my $str = shift;
    $str =~ y/\n\t\r //d;
    return $str;
}


1;
