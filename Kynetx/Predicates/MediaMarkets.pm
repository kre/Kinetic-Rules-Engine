package Kynetx::Predicates::MediaMarkets;
# file: Kynetx/Predicates/MediaMarkets.pm
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

###
### This module is depricated and no longer references from Kynetx::Modules
###


use strict;
#use warnings;

use Log::Log4perl qw(get_logger :levels);

use AnyDBM_File;
use Fcntl; # needed for O_ thingies

use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Predicates::Location qw(get_geoip);



use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_predicates
get_mediamarket
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


use constant DEFAULT_DB_DIR => '/web/lib/perl/etc/db/';


my %predicates = (

    'media_market_rank_greater_than' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $rank = get_mediamarket($req_info, 'rank');

	my $desired = $args->[0] || 0;
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
        $logger->debug("Media market rank: ". $rank . " ?< " . $desired);

	return int($rank) < int($desired);

    },

    'dma_is' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $dma = get_mediamarket($req_info, 'dma');

	my $desired = $args->[0] || 0;
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
        $logger->debug("Media market DMA: ". $dma . " =? " . $desired);

	return int($dma) == int($desired);

    },

);


sub get_predicates {
    return \%predicates;
}

sub get_mediamarket {
    my ($req_info, $field) = @_;

    my $logger = get_logger();

    my @field_names = qw(
                         dma
                         rank
                         name
                         households
                        );

    if(not defined $req_info->{'mediamarket'}->{$field}) {


	my $dma = get_geoip($req_info, 'dma_code');


	$logger->debug("[mediamarket] Using code $dma for DMA");


	# FIXME: hard coded URL
	
	my %demo;
	my $db_name = DEFAULT_DB_DIR .'dma.dbx';

	tie(%demo, 'AnyDBM_File', $db_name, O_RDONLY)
	    or die("can't open \%demo ($db_name): $!");
	

	my($rank,$name,$households) = 
	    split(/:/,$demo{$dma} || ":::");

	$logger->debug("Got from DMA dataset: ", $demo{$dma});
	


	$req_info->{'medaimarket'}->{'dma'} = $dma;
	$req_info->{'medaimarket'}->{'rank'} = $rank;
	$req_info->{'medaimarket'}->{'name'} = $name;
	$req_info->{'medaimarket'}->{'households'} = $households;
	
	untie(%demo);

    }

    return $req_info->{'medaimarket'}->{$field};

}




1;
