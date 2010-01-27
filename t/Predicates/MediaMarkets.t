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

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Predicates::MediaMarkets qw/:all/;
use Kynetx::JavaScript qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $preds = Kynetx::Predicates::MediaMarkets::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 2 + int(@pnames);


my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)


my $no_referer_req_info;
$no_referer_req_info->{'pool'} = APR::Pool->new;

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (200);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($Amazon_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


my($krl_src,$cond,$args);

$krl_src = <<_KRL_;
media_market_greater_than(500)
_KRL_

$cond = Kynetx::Parser::parse_expr($krl_src);

$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

#diag(Dumper($args));


ok(&{$preds->{'media_market_rank_greater_than'}}($Amazon_req_info,\%rule_env,$args),
   "Media market rank predicate");

$krl_src = <<_KRL_;
dma_is(819)
_KRL_

$cond = Kynetx::Parser::parse_expr($krl_src);

$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});



ok(&{$preds->{'dma_is'}}($Amazon_req_info,\%rule_env,$args),
   "Seattle's DMA is 819");


1;


