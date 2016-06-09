package Kynetx::System::Ruleset;
# file: Kynetx/System/Ruleset.pm
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


use Kynetx::Persistence::Application;# qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub system_rid {
     return Kynetx::Configure::get_config('SYSTEM_RID') || 'system';
}

sub write {
    my($var, $path, $value) = @_;
    my $rid = system_rid();
    my $status = 0;
    if (Kynetx::MongoDB::validate($value)) {
	$status = Kynetx::Persistence::Application::put_hash_app_element($rid,$var,$path,$value);
    }
    return $status;
}

sub read {
    my($var, $path) = @_;
    my $rid = system_rid();
    my $val = Kynetx::Persistence::Application::get_hash_app_element($rid,$var,$path);
    return $val
}

sub delete {
    my($var, $path) = @_;
    my $rid = system_rid();
    my $status = 0;
    if (defined $path) {
	$status = Kynetx::Persistence::Application::delete_hash_app_element($rid,$var,$path);
    } else {
	$status = Kynetx::Persistence::Application::delete($rid,$var);
    }
    return $status;
}


1;
