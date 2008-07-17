#!/usr/bin/perl -w

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
