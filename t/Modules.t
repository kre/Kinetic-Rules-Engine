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

use APR::Pool;
use LWP::Simple;
use XML::XPath;
use Cache::Memcached;
use Apache::Session::Memcached;
use DateTime;

use Kynetx::Test qw/:all/;
use Kynetx::Modules qw/:all/;
use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Environments qw(:all);
use Kynetx::Parser;
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::FakeReq qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

my $test_count = 0;

my $r = Kynetx::Test::configure();

# foreach my $k (sort @{Kynetx::Configure::config_keys()}) {
#   diag "$k => ", Kynetx::Configure::get_config($k);
# }

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

Kynetx::Test::gen_app_session($r, $my_req_info);

my($val);

$val = Kynetx::Modules::eval_module($my_req_info, $rule_env, $session, $rule_name, 'keys', 'errorstack', [] );
like($val,qr/\d+/,"Errorstack is a string a digits");
$test_count++;

$val = Kynetx::Modules::eval_module($my_req_info, $rule_env, $session, $rule_name, 'keys', 'googleanalytics', [] );
like($val,qr/\w\w\d+/,"Google is two chars and a string a digits");
$test_count++;

$val = Kynetx::Modules::eval_module($my_req_info, $rule_env, $session, $rule_name, 'keys', 'twitter', [] );
is_deeply($val,
	  {"consumer_key" => "5837874827498274939",
	   "consumer_secret" => "3HNb7NfdadadadahdajdhgajlkjakldaMtLahvkMt6Std5SO0"
	  },
	  "Twitter is a hash");
$test_count++;

done_testing($test_count);


1;


