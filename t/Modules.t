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

my $my_req_info = Kynetx::Test::gen_req_info($rid, {'ridver' => 'dev'});

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

#Kynetx::Test::gen_app_session($r, $my_req_info);

my($val, $js);

my $keys = {'consumer_secret' => '3HNb7NhKuqRIm2BuxKPSg6JYvMtLahvkMt6Std5SO0',
	    'consumer_key' => 'jPlIPAk1gbigEtonC2yNA'
	   };

# set up some keys
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'twitter',
  $keys);

($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'errorstack',
  '123456789812389');


($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'googleanalytics',
  'ab12184249284092384023942');


$val = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info, 
					 $rule_env, 
					 $session, 
					 $rule_name, 
					 'keys', 
					 'errorstack', 
					 [] 
					));
like($val,qr/\d+/,"Errorstack is a string a digits");
$test_count++;

$val = Kynetx::Modules::eval_module($my_req_info, $rule_env, $session, $rule_name, 'keys', 'googleanalytics', [] );
like($val,qr/\w\w\d+/,"Google is two chars and a string a digits");
$test_count++;

$val = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info, $rule_env, $session, $rule_name, 'keys', 'twitter', [] ));
is_deeply($val,
	  $keys,
	  "Twitter is a hash");
$test_count++;


my $source = 'uri';
my ($result,$args,$function);

$args = ['http://www.windley.com/archives?foo=bar'];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
				       $rule_env,
				       $session,
				       $rule_name,
				       $source,
				       'escape',
				       $args
				      ));


is($result,
   'http%3A%2F%2Fwww.windley.com%2Farchives%3Ffoo%3Dbar',
   'uri:escape');
$test_count++;

# now we reverse it
$args = [$result];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
				       $rule_env,
				       $session,
				       $rule_name,
				       $source,
				       'unescape',
				       $args
				      ));


is($result,
   'http://www.windley.com/archives?foo=bar',
   'uri:unescape (reverse last result)');
$test_count++;


# page
$source = "page";
$function = "env";
$args = ["caller"];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
				       $rule_env,
				       $session,
				       $rule_name,
				       $source,
				       $function,
				       $args
				      ));


is($result,
   'http://www.windley.com/',
   'page:env("caller")');
$test_count++;


$val = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info, 
					 $rule_env, 
					 $session, 
					 $rule_name, 
					 'meta', 
					 'rid', 
					 [] 
					));
is($val,'cs_test',"Meta data for RID");
$test_count++;

#diag "###########################";
#diag Dumper $my_req_info;

$val = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info, 
					 $rule_env, 
					 $session, 
					 $rule_name, 
					 'meta', 
					 'version', 
					 [] 
					));
is($val,'dev',"Meta data for ruleset version");
$test_count++;



#diag Dumper $rule_env;


done_testing($test_count);


1;


