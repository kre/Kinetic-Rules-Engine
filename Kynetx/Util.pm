package Kynetx::Util;
# file: Kynetx/Util.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ qw(debug_msg) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;




sub debug_msg {

    return if(not $r->dir_config('debug');

    my $label = shift;
    my $arg_str = join(', ',@_);


    $s->warn("$label: " . $arg_str);
}
