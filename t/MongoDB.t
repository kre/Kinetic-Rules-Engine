#!/usr/bin/perl -w

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
use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::Deep;
use Data::Dumper;
use MongoDB;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::MongoDB;

my $logger = get_logger();
my $num_tests = 0;

############
# Expected values
my $result;
my @result;
my $expected;
my $dictionary = 'dictionary';
my $global_iname = 'kynetx';
my $collections = ($dictionary);


Kynetx::Configure::configure();

Kynetx::MongoDB::init();

# Basic MongoDB commands
my $mdb = Kynetx::MongoDB::get_mongo();

# Check Database
@result = $mdb->collection_names();
$expected = superbagof($collections);
compare(\@result,$expected,"Has expected collections",0);

# Check Collection
my $coll = $mdb->get_collection($dictionary);
$result = $coll->find_one({'name' => $global_iname});
$expected = superhashof( {
    "_id" => ignore(),
    "name" => $global_iname
});
compare($result,$expected,"Kynetx inum",1);


sub compare {
    my ($got,$expected,$description,$diag) =@_;
    if ($diag) {
        $logger->debug("Test: $description: ", sub {Dumper($got)});
    }
    cmp_deeply($got,$expected,$description);
    $num_tests++;
}

plan tests => $num_tests;

1;


