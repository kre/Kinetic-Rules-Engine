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

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Predicates::Location qw/:all/;
use Kynetx::JavaScript qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $preds = Kynetx::Predicates::Location::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 2 + int(@pnames);


my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my $BBC_req_info;
$BBC_req_info->{'ip'} = '212.58.251.195'; # BBC, Surrey, Tadworth

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}



my($krl_src,$cond,$args);

$krl_src = <<_KRL_;
location:country()
_KRL_

$cond = Kynetx::Parser::parse_expr($krl_src);

$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

#diag(Dumper($args));



is(get_geoip($BYU_req_info,'region'),'UT',
   "BYU is in the UT");

is(get_geoip($BBC_req_info,'country_code'),'GB',
   "BBC is in the GB");




1;


