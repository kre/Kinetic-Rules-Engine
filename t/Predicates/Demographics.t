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
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Demographics qw/:all/;
my $preds = Kynetx::Predicates::Demographics::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 8 + int(@pnames);


my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

# Note: BYU zip not defined in demographics DB
my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();


# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


my $amazon_median_income = get_demographics($Amazon_req_info, 'median_income');
# my $byu_median_income = get_demographics($BYU_req_info, 'median_income');


ok(defined($amazon_median_income), "Median income not undef");

my @args = (10000);
ok(&{$preds->{'median_income_above'}}
       ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income greater than 10000");


ok(! &{$preds->{'median_income_below'}}
       ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income greater than 10000");

@args = (20000);
ok(! &{$preds->{'median_income_above'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income not greater than 20000");

ok(&{$preds->{'median_income_below'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income not greater than 20000");


@args = (10000,20000);
ok(&{$preds->{'median_income_between'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income between 10000 and 20000");


ok(&{$preds->{'urban'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon is urban");

ok(! &{$preds->{'rural'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon is not rural");



1;


