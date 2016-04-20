package lib::ConfMaker;

# file: bin/perl/ConfMaker.pm

# This file is part of the Kinetic Rules Engine (KRE) Install Scripts
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
no warnings 'all';

use lib qw (
  /web/lib/perl
);

use File::Slurp;
use File::Copy;
use File::Basename;
use IO::File;
use Data::Dumper;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"

our %EXPORT_TAGS = (all => [
  qw(
    ask
    q_single
    q_array
    read_section
    write_section
    restart_apache
    rotate_file
    collections_from_config
    DEFAULT_OWNER_USERNAME
  )]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant SEP => ",";
use constant DEFAULT_OWNER_USERNAME => "_web_";

sub restart_apache {
  my $command = "sudo /sbin/service httpd restart";
  my $status = system($command);
  return $status;
}

sub read_section {
  my ($file) = @_;
  my $tag;
  my $questions;
  my $fh = IO::File->new();
  $fh->open($file);
  while (<$fh>) {
    my $line = $_;
    chop $line;
    next if ($line =~ /^#/);
    my ($key,$default,$description) = split(SEP,$line);
    $questions->{$key} = {
      'default' => $default,
      'desc' => $description
    };
  }
  $fh->close();
  return $questions;
}

sub ask {
  my ($q) = @_;
  my ($type,$desc,$var,$def) = @{$q};
  my $ans;
  if (defined $type && $type ne "") {
    $ans = q_array($desc,$var,$def);
    return ($type, $ans);
  } else {
    return ($var, q_single($desc,$var,$def));
  }
}

sub q_single {
  my ($q) = @_;
  my $desc = $q->{'desc'};
  my $def = $q->{'default'};
  print "$desc: ($def) ";
  my $temp = <STDIN>;
  chop $temp;
  if ($temp) {
    return $temp 
  } else {
    return $def
  }
}

sub q_array {
  my ($key,$q) = @_;
  my $desc = $q->{'desc'};
  my $def = $q->{'default'};
  print "$key\n";
  print "$desc: ($def) ";
  my $input;
  my @array = ();
  do {
    $input = <STDIN>;
    chop $input;
    if ($input) {
      push(@array,{ $key => $input});
    } else {
     print "$desc: <press ENTER to quit> "; 
    }
  } until ($input eq  "");
  if (scalar @array == 0) {
    push (@array,{ $key => $def});
  } 
  return \@array;
}

sub write_section {
  my ($file,$tag,$description,$lines) = @_;
  my @old = read_file($file);
  my @new = ();
  my $prune = 0;
  my $found = 0;
  foreach my $line (@old) {
    push(@new,$line) unless ($prune);
    if ($line =~ m/^$tag/) {
      print "Replace section $tag\n";
      $prune = 1;
      $found = 1;
      foreach my $newline (@{$lines}) {
        push(@new,$newline);
      }
    } elsif ($prune && $line =~ m/^#/) {
      $prune = 0;
      push(@new,"\n");
      push(@new,$line);
    }
  }
  if (! $found) {
    print "Append section $tag\n";
    my $eof = pop(@new);
    push(@new, "\n$tag\n");
    foreach my $newline (@{$lines}) {
      push(@new,$newline);
    }
    push(@new,$eof);
  }
  write_file($file,@new);
}

sub rotate_file {
  my ($filename,$new_data) = @_;
  my $root;
  my @parts = split(/\./,$filename);
  if (scalar @parts > 1) {
    pop(@parts);
    $root = join(".",@parts);
  } else {
    $root = $filename;
  }
  my $suffix = time();
  my $oldfile = $root . "." . $suffix;
  my $backdir = File::Basename::dirname($filename);
  print "Backup: $backdir\n";
  print "Root: $root\n";
  my @stale = glob "$root.[0123456789]*";
  foreach my $file (@stale) {
    print "\tFile: $file\n";
    move($file,"$backdir/bak/");
  }
  
  
  

  if (-e $filename && -w _) {
    print "Copy $filename to $oldfile\n";
    move($filename,$oldfile) or die "Move failed: $!";
  }
  my $fh = IO::File->new();
  $fh->open("> $filename");
  print $fh $new_data;
  $fh->close();
  return $oldfile;    

}

sub collections_from_config {
  my $mongo_scripts = "../files/mongo*.js";
  my @list = `grep -h ensureIndex $mongo_scripts`;
  my $tmp;
  map {$tmp->{$_} = 1} map { /db\.(\w+?)\./ } @list;
  return keys %{$tmp};
}

1;
