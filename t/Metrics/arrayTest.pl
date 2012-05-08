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
use Cache::Memcached;
use Benchmark ':hireswallclock';
use Clone qw(clone);
use Devel::Size qw(
  size
  total_size
);

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached;
use Kynetx::Expressions;
use Metrics::Datapoint;
use Devel::Size;

my $logger = get_logger();
my $num_tests = 0;

############
# Expected values
my $result;
my @result;
my $expected;
my $dictionary = 'dictionary';
my $global_iname = 'kynetx';
my $frid = "test64x192";
my $fken = "4ce175b9ba381431de46e6d7";

#my $collections = ($dictionary,'edata','appdata','kens','tokens');
my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $what = $DICTIONARY[rand(@DICTIONARY)];
my $who = $DICTIONARY[rand(@DICTIONARY)];
my $where = $DICTIONARY[rand(@DICTIONARY)];
my $yav = $DICTIONARY[rand(@DICTIONARY)];
chomp($what);
chomp($where);
chomp($who);
chomp($yav);

$logger->debug("Who:   $who");
$logger->debug("What:  $what");
$logger->debug("Where: $where");

Kynetx::Configure::configure();

Kynetx::MongoDB::init();

Kynetx::Memcached->init();

# Basic MongoDB commands
my $mdb = Kynetx::MongoDB::get_mongo();


sub build_array {
	my ($max) = @_;
	my $array_val = ();
	for (my $i = 0; $i < $max; $i++) {
		my $yav = $DICTIONARY[rand(@DICTIONARY)];
		chomp($yav);
		push(@$array_val,$yav);	
	}	
	return $array_val;
}

my $rid = "fake_rule_1";
my $varp = "aaaaaaabaaaaaaa";
my $array_ref;
my $kval;
my $asize;
my $tsize;
my $var;

# init the datapoints
my $put = new Metrics::Datapoint({series => "array_test_put"});
my $get = new Metrics::Datapoint({series => "array_test_get"});
my $del = new Metrics::Datapoint({series => "array_test_del"});
my $update = new Metrics::Datapoint({series => "array_test_upd"});

$asize = 100;
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;
$logger->debug("R: ",sub {Dumper($result)});

$asize = 500;
$put = new Metrics::Datapoint({series => "array_test_put"});
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;

$asize = 1000;
$put = new Metrics::Datapoint({series => "array_test_put"});
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;

$asize = 5000;
$put = new Metrics::Datapoint({series => "array_test_put"});
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;


$asize = 10000;
$put = new Metrics::Datapoint({series => "array_test_put"});
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;

$asize = 50000;
$put = new Metrics::Datapoint({series => "array_test_put"});
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;


$asize = 100000;
$put = new Metrics::Datapoint({series => "array_test_put"});
$var = $varp . $asize;
$array_ref = build_array($asize);
$tsize = Devel::Size::total_size($array_ref);
$put->tags($asize);
$put->push("var_size",$tsize);
$put->start_timer;
$result = Kynetx::Persistence::Entity::put_edatum($rid,$fken,$var,$array_ref);
$put->stop_timer;
$put->store;


# gets
$asize = 100;
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;

$asize = 500;
$get = new Metrics::Datapoint({series => "array_test_get"});
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;

$asize = 1000;
$get = new Metrics::Datapoint({series => "array_test_get"});
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;

$asize = 5000;
$get = new Metrics::Datapoint({series => "array_test_get"});
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;

$asize = 10000;
$get = new Metrics::Datapoint({series => "array_test_get"});
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;

$asize = 50000;
$get = new Metrics::Datapoint({series => "array_test_get"});
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;


$asize = 100000;
$get = new Metrics::Datapoint({series => "array_test_get"});
$var = $varp . $asize;
$get->tags($asize);
$get->start_timer;
$result = Kynetx::Persistence::Entity::get_edatum($rid,$fken,$var);
$get->stop_timer;
$tsize = Devel::Size::total_size($result);
$get->push("var_size",$tsize);
$get->store;

# deletes
$asize = 100;
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;

$asize = 500;
$del = new Metrics::Datapoint({series => "array_test_del"});
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;


$asize = 1000;
$del = new Metrics::Datapoint({series => "array_test_del"});
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;

$asize = 5000;
$del = new Metrics::Datapoint({series => "array_test_del"});
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;


$asize = 10000;
$del = new Metrics::Datapoint({series => "array_test_del"});
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;

$asize = 50000;
$del = new Metrics::Datapoint({series => "array_test_del"});
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;


$asize = 100000;
$del = new Metrics::Datapoint({series => "array_test_del"});
$var = $varp . $asize;
$del->tags($asize);
$del->start_timer;
$result = Kynetx::Persistence::Entity::delete_edatum($rid,$fken,$var);
$del->stop_timer;
$del->push("var_size",0);
$del->store;

$result = Metrics::Datapoint::get_data("array_test_put");
for (my $i =0; $i< scalar(@{$result}) -1;$i++) {	
		 my $dp = $result->[$i];
		 $logger->debug("$i ", sub {Dumper($dp)});
		 $logger->debug("$i ", sub {Dumper($dp->get_metric("var_size"))});
		 $logger->debug("$i ", sub {Dumper($dp->get_metric("realtime"))});
	}

1;


