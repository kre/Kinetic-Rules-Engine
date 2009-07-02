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

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Predicates::Markets qw/:all/;
use Kynetx::JavaScript qw/:all/;


use LWP::Simple;
use XML::XPath;
use DateTime;
use LWP::UserAgent;

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Weather qw/:all/;

my $preds = Kynetx::Predicates::Markets::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 3 + int(@pnames);

my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}



SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=GOOG";

    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", 3 if (! $response->is_success);


    my($krl_src,$cond,$args);

    $krl_src = <<_KRL_;
foo(10)
_KRL_

    $cond = Kynetx::Parser::parse_predexpr($krl_src);

    $args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

#diag(Dumper($args));

    ok(&{$preds->{'djia_up_more_than'}}($BYU_req_info, \%rule_env, $args) ? 
       (! &{$preds->{'djia_down_more_than'}}($BYU_req_info, \%rule_env, $args)) :  
       1,
       "If the market's up, it's not down!");

    ok(&{$preds->{'djia_down_more_than'}}($BYU_req_info, \%rule_env, $args) ? 
       (! &{$preds->{'djia_up_more_than'}}($BYU_req_info, \%rule_env, $args)) :  
       1,
       "If the market's down, it's not up!");

    $krl_src = <<_KRL_;
foo('GOOG')
_KRL_

    $cond = Kynetx::Parser::parse_predexpr($krl_src);

    $args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});


    my $GOOG_last = get_stocks($BYU_req_info,"GOOG","last");
    diag("GOOG_last has value => $GOOG_last");
    ok(int($GOOG_last) > 0, 
       "GOOG's last isn't 0");
}

1;


