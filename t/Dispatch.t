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

use APR::URI;
use APR::Pool ();
use Cache::Memcached;


use JSON::XS;

use Kynetx::Test qw/:all/;
use Kynetx::Dispatch qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Repository;
use Kynetx::Memcached;
use Kynetx::FakeReq;
use Kynetx::Errors;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;



# my $numtests = 18;
# plan tests => $numtests;


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);


#my $my_req_info;
#$my_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)

# configure KNS
Kynetx::Configure::configure();


$my_req_info->{'rids'} = [{'rid' => 'cs_test',
			   'kinetic_app_version' => 'prod'},
			  {'rid' => 'cs_test_authz',
			   'kinetic_app_version' => 'prod'}];

my $test_count = 0;


is_string_nows(
    Kynetx::Dispatch::simple_dispatch($my_req_info,"cs_test;cs_test_1"), 
    '{"cs_test_1":["www.windley.com","www.kynetx.com"],"cs_test":["www.google.com","www.yahoo.com","www.live.com"]}',
    "Testing dispatch function with two RIDs");
$test_count++;

my $json = decode_json(Kynetx::Dispatch::extended_dispatch($my_req_info));

#diag Dumper $json;

is_deeply(
    $json, decode_json <<_EOF_
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
);

$test_count++;

my $result = Kynetx::Dispatch::calculate_dispatch($my_req_info);

is_deeply($result,
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
} 
);

$test_count++;


done_testing($test_count);
1;


