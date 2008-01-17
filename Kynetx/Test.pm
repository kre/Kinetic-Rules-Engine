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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



sub getkrl {
    my $filename = shift;

    open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
    my $first_line = <KRL>;
    local $/ = undef;
    my $krl = <KRL>;
    close KRL;
    # remove comments from KRL
    $krl =~ s!(.*)//[^\n]*!$1!og;
    return ($first_line,$krl);

}

1;
