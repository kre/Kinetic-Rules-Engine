#!/usr/bin/perl -w

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
use AnyDBM_File;
use Text::CSV;
use Fcntl; # needed for O_ thingies


open(DEMO, "dma.csv");

my %demo;
my $db_name = 'dba.dbx';

tie(%demo, 'AnyDBM_File', $db_name, O_RDWR|O_CREAT, 0640)
    or die("can't create \%demo: $!");


my $csv = Text::CSV->new();

# DMA,Rank,Name,TV Households,,,,,,
while(<DEMO>) {
    next unless $csv->parse($_);

    my @line = $csv->fields;
    my $dma = $line[0];
    my $rank = $line[1];
    my $name = $line[2];
    my $households = $line[3];

    my $out = join(":",($rank,$name,$households));
    print $out, "\n";
    $demo{$dma} = $out;
	
}

untie(%demo);
