package Kynetx::Predicates::MediaMarkets;
# file: Kynetx/Predicates/MediaMarkets.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
# 
use strict;
use warnings;

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
