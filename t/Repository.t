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

# use APR::URI;
# use APR::Pool ();
use Data::Dumper;

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
use Kynetx::Parser qw/:all/;




my $req_info;
$req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)


my %rule_env = ();


plan tests => 5;


#
# Repository tests
#

# configure KNS
Kynetx::Configure::configure();

Kynetx::Memcached->init();
my $logger = get_logger();

sub get_local_rule {
  my $filename = shift;
  
}


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
    skip "Can't get rules for " . get_rid($rid_info) . " ", $how_many if $@;

    is_deeply($rules0->{'rules'}, $rules1->{'rules'});

}

my $description = "Get a ruleset from github (raw)";
my $local_file = 'data/action5.krl';
my ($fl,$krl_text) = getkrl($local_file);
my $ast = Kynetx::Rules::optimize_ruleset(parse_ruleset($krl_text));
$ast->{'rules'}->[0]->{'event_sm'} = ignore();
my $rulename = $ast->{"ruleset_name"};
my $uri = "https://raw.github.com/kre/Kinetic-Rules-Engine/master/t/" . $local_file;
my $rid_info = mk_rid_info($req_info,$rulename);
$rid_info->{'uri'} = $uri;
$req_info->{'rid'} = $rid_info;
my $rules = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);
#$logger->debug("Rule: ", sub {Dumper($rules->{'rules'})});
cmp_deeply($rules->{'rules'},$ast->{'rules'},$description);


my $file_uri = "file://$local_file";
$description = "Check local filesystem for ruleset";
$rid_info->{'uri'} = $file_uri;
$rules = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);
cmp_deeply($rules,$ast,$description);


my $xdi_uri = 'xri://=!7F81.A40.9F16.59BB!50ac25bd69983c9526020000+cloudOS$*(+ruleset)$!1';
$description = "Check XDI for ruleset";
$rid_info->{'uri'} = $xdi_uri;
$rid_info->{'username'} =  '=!7F81.A40.9F16.59BB!50ac25bd69983c9526020000';
$rid_info->{'password'} =  'caroteel';
$rules = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);
#$logger->debug("Rule: ", sub {Dumper($rules)});
cmp_deeply($rules,$ast,$description);


1;


