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

# use APR::URI;
# use APR::Pool ();

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Cache::Memcached;


use Kynetx::Test qw/:all/;
use Kynetx::Repository qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Rids qw/:all/;




my $req_info;
$req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)


my %rule_env = ();


plan tests => 2;


#
# Repository tests
#

# configure KNS
Kynetx::Configure::configure();

Kynetx::Memcached->init();

my $logger = get_logger();

# this test relies on a ruleset being available for site 10.
SKIP: {

    # this number must reflect the number of test in this SKIP block
    my $how_many = 1;

    my $rid_info = mk_rid_info($req_info, 'cs_test'); # the test rid_info.  
    $req_info->{'rid'} = $rid_info;

    my $rules ;
    eval {

      $rules = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);
	
    };
    skip "Can't get repository connection", $how_many if $@;

    ok(exists $rules->{'ruleset_name'});

}


SKIP: {

    # this number must reflect the number of test in this SKIP block
    my $how_many = 1;


    my ($rules0, $rules1);

    my $rid_info = mk_rid_info($req_info, 'cs_test'); # the test rid_info.  
    $req_info->{'rid'} = $rid_info;

    $logger->debug("Testing that rules are identical");
    $rules0 = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);

    eval {

	$rules1 = Kynetx::Rules::get_rules_from_repository($rid_info, $req_info);
	
    };
    skip "Can't get rules for ", get_rid($rid_info), " ", $how_many if $@;

    is_deeply($rules0->{'rules'}, $rules1->{'rules'});

}

1;


