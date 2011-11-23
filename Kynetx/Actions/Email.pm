package Kynetx::Actions::Email;
# file: Kynetx/Actions/Email.pm
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

use Kynetx::Directives qw/:all/;

my $default_actions = {
    forward => {
      directive => sub {
	my $req_info = shift;
	my $dd = shift;
	my $config = shift;
	my $args = shift;
	send_directive($req_info,
		       $dd,
		       'forward',
		       $config);
      },
    },
    send => {
      directive => sub {
	my $req_info = shift;
	my $dd = shift;
	my $config = shift;
	my $args = shift;
	send_directive($req_info,
		       $dd,
		       'send',
		       $config);
      },
    },
    reply => {
      directive => sub {
	my $req_info = shift;
	my $dd = shift;
	my $config = shift;
	my $args = shift;
	send_directive($req_info,
		       $dd,
		       'reply',
		       $config);
      },
    },
    delete => {
      directive => sub {
	my $req_info = shift;
	my $dd = shift;
	my $config = shift;
	my $args = shift;
	send_directive($req_info,
		       $dd,
		       'delete',
		       $config);
      },
    },
};



sub get_resources {
    return {};
}

sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return {};
}


1;
