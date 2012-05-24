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

use Test::More;

use Test::LongString;
use Test::Deep;
use Apache::Session::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::FakeReq;
use DateTime;
use Data::Dumper;
use Kynetx::Metrics::Datapoint qw(:all);
use Cache::Memcached;
use Benchmark ':hireswallclock';
use Clone qw(clone);
use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached;
use APR::URI qw/:all/;
use APR::Pool ();


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

Kynetx::Configure::configure();	

Kynetx::MongoDB::init();

Kynetx::Memcached->init();

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $num_test = 0;
my $rid = $DICTIONARY[rand(@DICTIONARY)];
chop $rid;
my $session = int(rand(1000000));
my $rulename = $DICTIONARY[rand(@DICTIONARY)];
chop $rulename;

my $req_info = Kynetx::Test::gen_req_info($rid);
my $rule_env = Kynetx::Test::gen_rule_env();

my $ts = DateTime->now->epoch();
my $dp = new Kynetx::Metrics::Datapoint;

my $dp1 = new Kynetx::Metrics::Datapoint;
is($ts - $dp->timestamp < 1,1,"Timestamp set");
$num_test++;

is($dp->isStarted,0,"Predicate: isStarted false");
$num_test++;

$dp->start_timer;
is($dp->isStarted,1,"Predicate: isStarted true");
$num_test++;

is($dp->isStopped,0,"Predicate: isStopped false");
$num_test++;

my $delta = 5;
my $fake_time = DateTime->now->epoch();
$fake_time -= $delta;
$dp1->timestamp($fake_time);

is($dp1->timestamp, $fake_time,"Set the timestamp");
$num_test++;
$dp1->stop_timer();

my $result = $dp1->get_metric('etime');
is($result,$delta,"Get existing metric");
$num_test++;

$logger->debug("D: ", sub {Dumper($dp1)});

$dp->stop_timer;
is($dp->isStopped,1,"Predicate: isStopped true");
$num_test++;

$result = $dp->get_metric('realtime');
is($result <1,1,"Benchmark timing");
$num_test++;

my @tags = qw(red blue green);
$dp->tags(\@tags);

#is($dp->tags(),@tags,"Set metric tags");
cmp_deeply($dp->tags->[2],"green","Set metric tags");
$num_test++;

$result = $dp->add_tag("orange");
push(@tags,"orange");
cmp_deeply($result,bag(@tags),"Add scalar to tags");
$num_test++;

my @temp = qw(chartruse maroon);

$result = $dp->add_tag(\@temp);
@tags = (@tags,qw(chartruse maroon));
$logger->debug("rTags: ", sub {Dumper($result)});
$logger->debug("Tags: ", sub {Dumper(@tags)});
cmp_deeply($result,bag(@tags),"Add array to tags");
$num_test++;

$dp->series('smoke');

$dp->push("rid",$rid);
$dp->push("rulename",$rulename);


$dp->tick();
my $max = int(rand(10000));
for (my $i = 0; $i < $max; $i++){
	$dp->tick();
}
$dp->tick(1);

$logger->debug("Count: ", $dp->count);

$dp->store();
$logger->debug(sub{Dumper($req_info)});

done_testing($num_test);

1;


