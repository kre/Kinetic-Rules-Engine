package Kynetx::Util;
# file: Kynetx/Util.pm

use strict;
use warnings;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
before_now
after_now
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub before_now {
    my $desired = shift;

    my $now = DateTime->now;

    # print("Comparing ", $now . " with " . $desired . "\n");

    # 1 if first greater than second
    return DateTime->compare($now,$desired) == 1;

}


sub after_now {
    my $desired = shift;

    return not before_now($desired);

}
