package Kynetx::ExecEnv;
# file: Kynetx/ExecEnv.pm
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
build_exec_env
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

#
# The ExecEnv holds the execution environment for a rule. This
# includes things like the condition variable for taking parallel
# action.  
#
# The ExecEnv differs from the rule environment in that the rule
# environment holds value created though the execution of the rule
# whereas the ExecEnv holds items that are not to be user (rule)
# created or accesible.
# 
# The ExecEnv differs form the request information in that it is not
# intended to be used by all the rulesets in the request or even all
# the rules in a ruleset. More of the things that have formerly been
# stored in the request info more properly belong in the ExecEnv
#


sub build_exec_env {
    my $logger = get_logger();
}

### condvar
sub set_condvar {
  my($self, $cv) = @_;

  $self->{'condvar'} = $cv;
}

sub get_condvar {
  my($self) = @_;

  return $self->{'condvar'};
}



1;
