package Kynetx::Persistence::KPDS;
# file: Kynetx/Persistence/KPDS.pm
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
use lib qw(
    /web/lib/perl
);


use Log::Log4perl qw(get_logger :levels);
use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Session qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use Kynetx::Errors;
use Kynetx::Persistence::KToken;
use Kynetx::Persistence::KEN;
use MongoDB;
use MongoDB::OID;

use Clone qw(clone);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
get_kpds_record
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant COLLECTION => "kpds";

sub get_kpds_element {
	my ($ken,$hkey) = @_;
	my $logger = get_logger();
	if (defined $ken) {
		my $key = {
			"ken" => $ken
		};
		my $result = Kynetx::MongoDB::get_hash_element(COLLECTION,$key,$hkey);
		if (defined $result && ref $result eq "HASH") {
			return $result->{"value"};
		} else {
			return undef;
		}
	} else {
		$logger->warn("KEN undefined in XDI information request");
 		return undef;		
	}
	
}

sub put_kpds_element {
	my ($ken,$hkey,$val) = @_;
	my $logger = get_logger();
	my $key = {
		'ken' => $ken
	};
	my $value = {
		'value' => $val
	};
	$logger->debug("Insert: $ken");
	my $success = Kynetx::MongoDB::put_hash_element(COLLECTION,$key,$hkey,$value);
	$logger->debug("Response: ", sub {Dumper($success)});
	return $success;
	
}

sub delete_kpds_element {
	my ($ken,$hkey) = @_;
	my $logger = get_logger();
	if (defined $ken) {
		my $key = {
			"ken" => $ken
		};
		if (defined $hkey) {
			Kynetx::MongoDB::delete_hash_element(COLLECTION,$key,$hkey);
		} else {
			$logger->warn("Attempted to delete $key in ", COLLECTION, " (use delete_kpds(<KEN>) )");
		}
	}
	
}

sub delete_kpds {
	my ($ken) = @_;
	my $logger = get_logger();
	if (defined $ken) {
		my $key = {
			"ken" => $ken
		};
		Kynetx::MongoDB::delete_value(COLLECTION,$key);
	}
	
}

1;