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

use APR::URI;
use APR::Pool ();
use Cache::Memcached;


use JSON::XS;

use Kynetx::Test qw/:all/;
use Kynetx::Operators qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Memcached;
use Kynetx::Postlude qw/:all/;
use Kynetx::Persistence qw/:all/;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);



# configure KNS
Kynetx::Configure::configure();



my $test_count = 0;


is_string_nows(
    Kynetx::Dispatch::simple_dispatch($my_req_info,"cs_test;cs_test_1"), 
    '{"cs_test_1":["www.windley.com","www.kynetx.com"],"cs_test":["www.google.com","www.yahoo.com","www.live.com"]}',
    "Testing dispatch function with two RIDs");
$test_count++;

my $json = decode_json(Kynetx::Dispatch::extended_dispatch($my_req_info));

#diag Dumper $json;

my $expected = decode_json <<_EOF_;
{
   "events":{
      "web":{
         "pageview":[
            {
               "pattern":"/([^/]+)/bar.html",
               "type":"url"
            },
            {
               "pattern":"/foo/bazz.html",
               "type":"url"
            },
            {
               "pattern":"/fizzer/fuzzer.html",
               "type":"default"
            },
            {
               "pattern":"/foo/bar.html",
               "type":"url"
            }
         ]
      }, 
      "system":{
         "error":[
            {
               "pattern":".*",
               "type":".*"
            }
         ]
      }
   },
   "cs_test_authz":{
      "events":{
         "web":{
            "pageview":[
               {
                  "pattern":"/foo/bar.html",
                  "type":"url"
               }
            ]
         }
      }
   },
   "cs_test":{
      "domains":[
         "www.google.com",
         "www.yahoo.com",
         "www.live.com"
      ],
      "events":{
         "web":{
            "pageview":[
               {
                  "pattern":"/([^/]+)/bar.html",
                  "type":"url"
               },
               {
                  "pattern":"/foo/bazz.html",
                  "type":"url"
               },
               {
                  "pattern":"/foo/bazz.html",
                  "type":"url"
               },
               {
                  "pattern":"/fizzer/fuzzer.html",
                  "type":"default"
               }
            ]
         },
         "system":{
            "error":[
               {
                  "pattern":".*",
                  "type":".*"
               }
            ]
         }
      }
   }
}
_EOF_

my $a = [#sub {return $_[0]->{events}->{system}->{error};},
	 #sub {return $_[0]->{events}->{web}->{pageview}->[0];},
	 sub {return $_[0]->{cs_test}->{domains};},
	 sub {return $_[0]->{cs_test}->{events}->{web}->{pageview}->[2];},
	];

for my $f ( @{$a} ) {
  my $res = &$f($expected);
  is_deeply(&$f($json), $res, Dumper $res);
  $test_count++;
}

my $result = Kynetx::Dispatch::calculate_dispatch($my_req_info);

#diag Dumper $result;

$expected = 
{
   "cs_test_authz"=>{
      "events"=>{
         "web"=>{
            "pageview"=>[
               {
                  "pattern"=>"/foo/bar.html",
                  "type"=>"url"
               }
            ]
         }
      }
   },
   "event_rids"=>{
      "web"=>{
         "pageview"=>[
            "cs_test",
            "cs_test_authz"
         ]
      },
      "system"=>{
         "error"=>[
            "cs_test"
         ]
      }
   },
   "events"=>{
      "web"=>{
         "pageview"=>[
            {
               "pattern"=>"/([^/]+)/bar.html",
               "type"=>"url"
            },
            {
               "pattern"=>"/foo/bazz.html",
               "type"=>"url"
            },
            {
               "pattern"=>"/fizzer/fuzzer.html",
               "type"=>"default"
            },
            {
               "pattern"=>"/foo/bar.html",
               "type"=>"url"
            }
         ]
      },
      "system"=>{
         "error"=>[
            {
               "pattern"=>".*",
               "type"=>".*"
            }
         ]
      }
   },
   "cs_test"=>{
      "domains"=>[
         "www.google.com",
         "www.yahoo.com",
         "www.live.com"
      ],
      "events"=>{
         "web"=>{
            "pageview"=>[
               {
                  "pattern"=>"/([^/]+)/bar.html",
                  "type"=>"url"
               },
               {
                  "pattern"=>"/foo/bazz.html",
                  "type"=>"url"
               },
               {
                  "pattern"=>"/foo/bazz.html",
                  "type"=>"url"
               },
               {
                  "pattern"=>"/fizzer/fuzzer.html",
                  "type"=>"default"
               }
            ]
         },
         "system"=>{
            "error"=>[
               {
                  "pattern"=>".*",
                  "type"=>".*"
               }
            ]
         }
      }
   }
} ;


$a = [sub {return $_[0]->{event_rids}->{web}->{pageview};},
      sub {return $_[0]->{cs_test}->{domains};},
      sub {return $_[0]->{cs_test}->{events}->{web}->{pageview}->[2];},
     ];

for my $f ( @{$a} ) {
  my $res = &$f($expected);
  is_deeply(&$f($result), $res, Dumper $res);
  $test_count++;
}


######################## Ridlist caching
#Log::Log4perl->easy_init($DEBUG);
my ($description,$expected,$key,$temp);

my $mod_rid = 'a144x172.prod';
my @default_rules = ['cs_test','10','a144x171.dev',$mod_rid];
my $test_env = Kynetx::Test::enchilada('ridlist','ridlist_rule',\@default_rules);
$logger->debug("Dump: ",sub {Dumper($test_env)});

subtest 'Environment created' => sub {Kynetx::Test::validate_env($test_env)};
$test_count++;

######################### Test Environment definitions
my $req_info = $test_env->{'req_info'};
my $sky_info = $test_env->{'sky_request_info'};
my $rule_env = $test_env->{'root_env'};
my $session  = $test_env->{'session'};
my $rulename = $test_env->{'rulename'};

my $anon_ken = $test_env->{'anonymous_user'};

my $user_ken = $test_env->{'user_ken'};
my $user_eci = $test_env->{'user_eci'};
my $user_username = $test_env->{'username'};
my $user_password = $test_env->{'password'};

my $t_rid = $test_env->{'rid'};
my $t_eid = $test_env->{'eid'};
#########################

$description = "Get ridlist";
$result = Kynetx::Dispatch::get_ridlist($req_info,$user_eci,$user_ken);
isnt(scalar @{$result},scalar @default_rules,$description);
$test_count++;

$description = "RID has last_modifed";
$expected = {
  'rid' => ignore(),
  'kinetic_app_version' => any('prod','dev'),
  'last_modified' => re(qr/\d+/),
  'owner' => ignore()
};
cmp_deeply($result,superbagof($expected),$description);
$test_count++;
$temp = $result;

$description = "Check cache for ridlist";
$key = Kynetx::Dispatch::mk_ridlist_key($user_ken);
$result = Kynetx::Memcached::check_cache($key);
cmp_deeply($result,$temp,$description);
$test_count++;

$description = "Compare rid_list copy from cache";
$result = Kynetx::Dispatch::get_ridlist($req_info,$user_eci,$user_ken);
cmp_deeply($result,$temp,$description);
$test_count++;

$description = "Calculate the eventtree key";
$result = Kynetx::Dispatch::mk_eventtree_key($temp);
isnt($result,undef,$description);
$test_count++;

my $sig0 = $result;
$logger->debug("E Key: $sig0");

$description = "Compute the eventtree for a session";
$result = Kynetx::Dispatch::calculate_rid_list($sky_info,$session);
isnt($result,undef,$description);
$test_count++;

my $etree = $result;

$description = "Check memcache for eventtree";
$result = Kynetx::Memcached::check_cache($sig0);
cmp_deeply($result,$etree,$description);
$test_count++;

$description = "calculate_rid_list uses the cached copy";
$result = Kynetx::Dispatch::calculate_rid_list($sky_info,$session);
cmp_deeply($result,$etree,$description);
$test_count++;

$description = "RID flush forces new eventtree key";
$temp = Kynetx::Dispatch::get_ridlist($req_info,$user_eci,$user_ken);
Kynetx::Modules::RSM::_flush($mod_rid);
$result = Kynetx::Dispatch::mk_eventtree_key($temp);
isnt($result,$sig0,$description);
$test_count++;

############################
# Entity var searching
Log::Log4perl->easy_init($DEBUG);

$logger->debug("Foo!");

$description = "Optimized query";
my $map = Kynetx::Test::twitter_query_map($req_info,$rule_env,$session,$rid);

$logger->debug("Twitter query: ", sub {Dumper($map)});

my $ekey = "searchkey";
$result = save_persistent_var("ent",$rid,$session,$ekey,$map);
my $map_check = Kynetx::MongoDB::get_value("edata",$ekey);

cmp_deeply($map,$map_check,$description);
$test_count++;

Log::Log4perl->easy_init($INFO);



#is_deeply($result, $foo);

#$test_count++;

######################### Clean up
Kynetx::Test::flush_test_user($user_ken,$user_username);

my $anon_uname = "_" . $anon_ken;
Kynetx::Test::flush_test_user($anon_ken,$anon_uname);



done_testing($test_count);
1;


