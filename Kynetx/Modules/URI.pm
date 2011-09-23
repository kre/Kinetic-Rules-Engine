package Kynetx::Modules::URI;
# file: Kynetx/Modules/URI.pm
# file: Kynetx/Predicates/Referers.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use URI::Escape;

my $predicates = {
};

my $default_actions = {
};

sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}



sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();

    my $resp = '';
    if($function eq 'escape') {
      $resp = uri_escape_utf8($args->[0]);
    } elsif($function eq 'unescape') {
      $resp = uri_unescape($args->[0]);
    } else {
      $logger->warn("Unknown function '$function' called in URI library");
    }

    return $resp;
}



1;
