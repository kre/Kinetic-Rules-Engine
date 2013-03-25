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
use lib qw(/web/lib/perl);
use strict;

use Data::Dumper;
use MongoDB;
use Carp;
use Cache::Memcached;
use Benchmark ':hireswallclock';
use Clone qw(clone);
use Getopt::Std;
use Time::HiRes qw(
	sleep
	usleep
);


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);


no warnings "all";

my $logger = get_logger();
my $num_tests = 0;

my $cken = "kens";
my $ctokens = "tokens";
my $cedata = "edata";
my $ckpds = "kpds";
my $cuserstate = "userstate";

use vars qw(
  %opt
);


my $opt_string = 't:f:';
getopts( "$opt_string", \%opt );

my $def_ts = 1363727104;
my $ts;
my $filename = '/tmp/valid_kens';

if ($opt{'t'}) {
	$ts = $opt{'t'} || $def_ts;
	$logger->debug("TS: $ts");	
}
$ts  = $ts || $def_ts;

if ($opt{'f'}) {
  $filename = $opt{'f'} || $filename;
}


# Basic MongoDB commands
my $mongo_server = "mongodb-02.kobj.net";
my $mongo_port = "27017";
my $mongo_db = "kynetx";
my $timeout = 60000;

my $MONGO = MongoDB::Connection->new(host => $mongo_server,find_master =>1,query_timeout =>$timeout);
my $db = $MONGO->get_database($mongo_db);
my $collection;
my $section = 1000;

my $ken_is_valid;

my $fh = IO::File->new("< $filename");
while (<$fh>) {
  my $ken = $_;
  chop $ken;
  $ken_is_valid->{$ken}++
}

if (defined $fh){
  $fh->close;
} else {
  carp "Filename: $filename not found";
}



my $ostart = new Benchmark;
my $count = 0;
my $s_times = ();
my $wait = 3;
my $limit = 100000;
my $microwait = 50;
my $collection = $db->get_collection('tokens');
my $key = {
  'last_active' => {'$lte' => $ts}
};
my $cursor = $collection->find($key)->sort({'last_active' => 1})->limit($limit);

my $start;
my $finish;

while ($cursor->has_next()) {
  if ($count++ == 0) {
    $start = new Benchmark;
    #print "Start: ", time(),"\n";
  };
  if ($count > $section){
    $finish = new Benchmark;
    my $tdiff = timediff($finish,$start);
    my $per = $tdiff->[0];
    push(@{$s_times},$per);
    my $mean = mean($s_times);
    my $deviation = $per - $mean;
    if ($deviation > 0) {
      $wait++;
      $microwait += 10;
      if ($deviation > 1) {
        $wait++
      }
    } elsif ($deviation < 0) {
      $wait--;
      $microwait -= 10;
      
    }
    if ($wait < 0) {
      $wait = 0;
    }
    if ($microwait < 0) {
      $microwait = 0;
    } elsif ($microwait > 100) {
      $microwait = 100;
    }
    #print "Finish: ", time(),"\n";
    print "Time: $per Difference: $deviation wait: $wait\n";
    sleep($wait);
    $count = 0;
  }
  my $token = $cursor->next;
  my $ken = $token->{'ken'};
  if ($ken_is_valid->{$ken}) {
    print "skip $ken\n";
  } else {
    delete_tokens($ken) unless (check_ken($ken));
    usleep($microwait);
  }
  
}
my $ofinish = new Benchmark;
my $odiff = timediff($ofinish,$ostart);
print "\n##Overall: $odiff->[0]\n";

sub check_ken {
  my ($ken) = @_;
  my $collection = $db->get_collection('kens');
  my $mid = MongoDB::OID->new(value => $ken);
  my $key = {
    '_id' => $mid
  };
  my $result = $collection->find_one($key);
  if (defined $result) {
    $ken_is_valid->{$ken}++;
    save_ken($ken);
    return 1;
  } else {
    return 0;
  }
  
}

sub save_ken {
  my ($ken) = @_;
  my $fh = IO::File->new(">> $filename");
  croak "Can't open $filename for append" unless ($fh);
  print $fh "$ken\n";
  $fh->close();
  print "Saved: $ken\n";
}

sub delete_userstate {
  my ($ken) = @_;
  my $collection = $db->get_collection('userstate');
  my $key = {
    'ken' => $ken
  };
  my $result = $collection->remove($key);
  list($result,'userstate');
  
}

sub delete_tokens {
  my ($ken) = @_;
  my $collection = $db->get_collection('tokens');
  my $key = {
    'ken' => $ken
  };
  my $result = $collection->remove($key);
  #my $result = $collection->find_one($key);
  list($result,'tokens');
}

sub delete_edata {
  my ($ken) = @_;
  my $collection = $db->get_collection('edata');
  my $key = {
      'ken' => $ken,
  };
  my $result = $collection->remove($key);
  list($result,'edata');
    
  
}

sub list {
  my ($cursor, $collection) = @_;
  if ($cursor != 1){
    print "$collection: ", Dumper($cursor);
  } 
}

sub mean {
  my ($list) = @_;
  #print Dumper($list);
  my $num = scalar @{$list};
  my $sum = 0;
  for my $time (@{$list}) {
    $sum += $time;
  }
  my $m = $sum / $num;
  print "Average of $num is $m\n";
  return $m;
}

#my $total = $c->find($key)->count();
#$logger->debug("Count: $total");


my @nums;

$SIG{INT} = \&stats;

sub stats {
	exit(1);
}


1;





