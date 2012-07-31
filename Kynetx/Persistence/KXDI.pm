package Kynetx::Persistence::KXDI;
# file: Kynetx/Persistence/KXDI.pm
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
    /web/Workspace/perl_xdi/
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
use Kynetx::Persistence::KPDS;
use MongoDB;
use MongoDB::OID;

use HTTP::XDI;

use Clone qw(clone);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant PDS => "XDI";
use constant FROM_GRAPH => '@!3436.F6A6.3644.4D74';


sub put_iname {
	my ($ken,$iname) = @_;
	if (defined $iname) {
		my $hash_path = [PDS, 'iname'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$iname);		
	}	
}

sub get_iname {
	my ($ken,$iname) = @_;
	if (defined $iname) {
		my $hash_path = [PDS, 'iname'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path);		
	}
	
}

sub put_inumber {
	my ($ken,$inumber) = @_;
	if (defined $inumber) {
		my $hash_path = [PDS, 'inumber'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$inumber);		
	}
	
}

sub get_inumber {
	my ($ken,$inumber) = @_;
	if (defined $inumber) {
		my $hash_path = [PDS, 'inumber'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path);		
	}	
}

sub put_endpoint {
	my ($ken,$graph_endpoint) = @_;
	if (defined $graph_endpoint) {
		my $hash_path = [PDS, 'endpoint'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$graph_endpoint);		
	}	
	
}

sub get_endpoint {
	my ($ken,$graph_endpoint) = @_;
	if (defined $graph_endpoint) {
		my $hash_path = [PDS, 'endpoint'];
		Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);		
	}	
	
}

sub get_xdi {
	my ($ken) = @_;
	my $hash_path = [PDS];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);
}

sub put_xdi {
	my ($ken,$struct) = @_;
	my $hash_path = [PDS];
	Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$struct);
}

sub create_xdi_from_iname {
	my ($ken, $iname) = @_;
	my $logger = get_logger();
	if ($ken && $iname) {
		my $xdi = new HTTP::XDI;
		my $discovery = $xdi->discovery($iname);
		$logger->debug("Disc: ", sub {Dumper($discovery)});
		my $uri = HTTP::XDI::get_xdi_uri($discovery);
		my $inumber = HTTP::XDI::get_xdi_inumber($discovery,$iname);
		$logger->debug("URI: ", sub {Dumper($uri)});
		$logger->debug("inumber: ", sub {Dumper($inumber)});
		my $struct = {
			'endpoint' => $uri,
			'inumber'  => $inumber,
			'iname'    => $iname
		};
		return put_xdi($ken,$struct);		
	} else {
		return undef;
	}
	
	
}

1;