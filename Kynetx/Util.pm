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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub before_now {
    my $desired = shift;

    my $now = DateTime->now;

#    debug_msg("Comparing", $now . " with " . $desired);

    # 1 if first greater than second
    return DateTime->compare($desired,$now) == 1;

}

