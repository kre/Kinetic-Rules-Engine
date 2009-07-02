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


