package Metrics::TENX;
# file: Metrics/TENX.pm
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
#use warnings;
use utf8;
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);
use Log::Log4perl::Level;

use Kynetx::Memcached qw(:all);
use URI::Escape ('uri_escape_utf8');
use Sys::Hostname;
use Kynetx::Configure;
use Kynetx::Persistence::KEN;
use Kynetx::Environments;

use Data::Dumper;

use constant V10X => "v10x";

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
in_time
V10X
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub in_time {
     my ($req_info, $rule_env, $rule_name, $session, $newtag) = @_;  
     my $logger = get_logger();
     my @tags = Kynetx::Environments::lookup_rule_env(+V10X,$rule_env) || ();
     push(@tags,$newtag);
     $logger->debug("Tags: ", sub {Dumper(@tags)});
     return Kynetx::Environments::extend_rule_env([+V10X ], [\@tags] ,$rule_env);
     #return $rule_env;
}

1;
