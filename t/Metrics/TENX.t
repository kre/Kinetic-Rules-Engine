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
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use Benchmark ':hireswallclock';


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions::JQueryUI qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Metrics::TENX;
use Kynetx::Persistence::Ruleset qw/:all/;

use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;


my $logger = get_logger();

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $num_test = 0;
my $rid = $DICTIONARY[rand(@DICTIONARY)];
chop $rid;
my $rulename = $DICTIONARY[rand(@DICTIONARY)];
chop $rulename;

my $r = Kynetx::Test::configure();
my $req_info = Kynetx::Test::gen_req_info($rid);
my $rule_env = Kynetx::Test::gen_rule_env();
my $session = Kynetx::Test::gen_session($r, $rid);

my ($start,$stop,$diff,@vals,$result,$description,$expected);
my @vars = ( 'realtime', 'usertime', 'systime', 'cusertime', 'csystime', 'cpu' );

my $key = {};
my $filter = ();
my $limits = {};


$description = "Check an 'any' request";
$start = new Benchmark();
$result = Kynetx::Metrics::TENX::_get_datapoints($key,$limits,$filter);
$stop = new Benchmark();
$diff = timediff( $stop, $start );
@vals = @$diff;
$logger->trace("1000: ",$vals[0]);
cmp_deeply([keys(%{$result})],array_each(re(qr/\w+/)),$description);
$num_test++;

$logger->trace("Series: ",sub {Dumper(keys(%{$result}))});

$description = "Multiple series";
my $path = "sky;ts;realtime/use-module;ts;realtime?";
$result = Kynetx::Metrics::TENX::get_series($path,{'limit' => 10000});
cmp_deeply([keys(%{$result})],bag(('sky','use-module')),$description);
$num_test++;

$logger->trace("Series: ",sub {Dumper(keys(%{$result}))});

$description = "Check an 'any' request for multiple series";
$path = "any;ts;realtime?";
$result = Kynetx::Metrics::TENX::get_series($path,{'limit' => 1000});
cmp_deeply([keys(%{$result})],array_each(re(qr/\w+/)),$description);
$num_test++;

$logger->trace("Series: ",sub {Dumper(keys(%{$result}))});

$description = "Check an empty request";
$path = "any;ts;realtime";
$expected = {'any' => {
  'xname' => 'ts',
  'yname' => 'realtime'
}};
$result = Kynetx::Metrics::TENX::get_series($path,{'limit' => 1000,'eid'=>5});
cmp_deeply($result,$expected,$description);
$num_test++;

$logger->trace("Series: ",sub {Dumper(keys(%{$result}))});

done_testing($num_test);

1;


