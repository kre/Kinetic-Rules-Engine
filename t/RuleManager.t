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
use Test::WWW::Mechanize;

use LWP::UserAgent;

use Apache2::Const;
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::FakeReq qw/:all/;
use Kynetx::Test qw/:all/;
use Kynetx::RuleManager qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Json;

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Kynetx::Configure;

Kynetx::Configure::configure();

Kynetx::Memcached->init();

my $memd = get_memd();


my $numtests = 81;
my $nonskippable = 15;
plan tests => $numtests;

my $my_req_info = {};

my $r = new Kynetx::FakeReq();


my $dn = "http://127.0.0.1/manage";

my $ruleset = "cs_test";

my $test_ruleset = <<RULESET;
ruleset 10 {
  rule test_choose is inactive {
    select using "/identity-policy/" setting ()


    if time:daytime() then
    choose {
        first_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_2.inc")
	   with tags = ["discount", "blue"] and
	        draggable = true;

    }


    callbacks {
      success {
        click id="rssfeed";
        click class="newsletter"
      }

      failure {
        click id="close_rss"
      }

    }

  }

}
RULESET

my $test_ruleset_bad = <<RULESET;
ruleset 10 {
    rule {}
    ;;;
}
RULESET


my $test_json_ruleset = <<JSON;
{"global":[],
 "dispatch":[],
 "rules":[
    {"cond": {
            "source":"time",
            "predicate":"daytime",
            "args":[],
            "type":"qualified"
    },
    "blocktype":"choose",
    "actions":[
        {"action":{
            "source":null,
            "name":"replace",
            "args":[
              {
                "val":"kobj_test",
                "type":"str"
              },
              {
                "val":"/kynetx/newsletter_invite_1.inc",
                "type":"str"
              }],
            "modifiers":[
              {"value":{
                  "val":[
                    {
                      "val":"gift certificate",
                      "type":"str"
                    },
                    {
                      "val":"yellow",
                      "type":"str"
                    }],
                "type":"array"
               },
               "name":"tags"},
              {"value":{
                  "val":30,
                  "type":"num"},
                  "name":"delay"}],
             "vars":null},
             "label":"first_rule_name"},
          {"action":{
              "source":null,
              "name":"replace",
              "args":[
                {
                    "val":"kobj_test",
                    "type":"str"
                },
                {
                    "val":"/kynetx/newsletter_invite_2.inc",
                    "type":"str"
                }],
              "modifiers":[
                {"value":{
                    "val":[
                      {
                          "val":"discount",
                          "type":"str"
                      },
                      {
                          "val":"blue",
                          "type":"str"
                      }],
                  "type":"array"},
                "name":"tags"},
                {"value":{
                    "val":"true",
                    "type":"bool"},
                 "name":"draggable"}],
              "vars":null},
            "label":"second_rule_name"}],
          "post":null,
          "pre":[],
          "name":"test_choose",
          "emit":null,
          "state":"inactive",
          "callbacks":{
              "success":[
                {"attribute":"id",
                 "trigger" : null,
                 "value":"rssfeed",
                 "type":"click"},
                {"attribute":"class",
                 "trigger" : null,
                 "value":"newsletter",
                 "type":"click"}
                ],
               "failure":[
                 {"attribute":"id",
                  "trigger" : null,
                  "value":"close_rss",
                  "type":"click"}
                ]},
           "pagetype": {
               "event_expr": {
                   "pattern":"/identity-policy/",
                   "legacy": 1,
                   "type":"prim_event",
                   "vars":[],
                   "op":"pageview"},
               "foreach":[]}}],
     "meta":{},
     "ruleset_name":"10"}
JSON

#"ruleset_name":"10",

my $test_json_rule = <<JSON;
{"cond":{
    "source":"time",
    "predicate":"daytime",
    "args":[],
    "type":"qualified"},
 "blocktype":"choose",
 "actions":[
    {"action":{
        "source":null,
        "name":"replace",
        "args":[
            {"val":"kobj_test",
             "type":"str"},
            {"val":"/kynetx/newsletter_invite_1.inc",
             "type":"str"}],
        "modifiers":[
            {"value":{
                "val":[
                    {"val":"gift certificate",
                     "type":"str"},
                    {"val":"yellow",
                      "type":"str"}],
                "type":"array"},
             "name":"tags"},
            {"value":{
                "val":30,
                "type":"num"},
             "name":"delay"}],
        "vars":null},
        "label":"first_rule_name"},
     {"action":{
         "source":null,
         "name":"replace",
         "args":[
            {"val":"kobj_test",
             "type":"str"},
            {"val":"/kynetx/newsletter_invite_2.inc",
             "type":"str"}],
         "modifiers":[
            {"value":{
                "val":[
                  {"val":"discount",
                   "type":"str"},
                  {"val":"blue","type":"str"}],
                "type":"array"},
             "name":"tags"},
           {"value":{
             "val":"true",
             "type":"bool"},
             "name":"draggable"}],
             "vars":null},
            "label":"second_rule_name"}],
            "post":null,
            "pre":[],
            "name":"test_choose",
            "emit":null,
            "state":"inactive",
            "callbacks":{
                "success":[
                  {
                    "attribute":"id",
                    "trigger" : null,
                    "value":"rssfeed",
                    "type":"click"},
                  {
                    "attribute":"class",
                    "trigger" : null,
                    "value":"newsletter",
                    "type":"click"}],
                "failure":[
                  {
                    "attribute":"id",
                    "trigger" : null,
                    "value":"close_rss",
                    "type":"click"}]
            },
            "pagetype":{
                "event_expr":{
                    "pattern":"/identity-policy/",
                    "legacy": 1,
                    "type":"prim_event",
                    "vars":[],
                    "op":"pageview"},
            "foreach":[]
    }
}
JSON

my $test_rule = <<RULE;
rule test_choose is inactive {
    select using "/identity-policy/" setting ()

    if time:daytime() then
    choose {
        first_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_2.inc")
	   with tags = ["discount", "blue"] and
	        draggable = true;

    }


    callbacks {
      success {
        click id="rssfeed";
        click class="newsletter"
      }

      failure {
        click id="close_rss"
      }

    }

}
RULE




my $test_rule_bad = <<RULE;
rule test_choose is stupid {
  do not select anything here.
}
RULE


my $test_rule_body = <<RULEBODY;
    select using "/identity-policy/" setting ()

    if time:daytime() then
    choose {
        first_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_2.inc")
	   with tags = ["discount", "blue"] and
	        draggable = true;

    }


    callbacks {
      success {
        click id="rssfeed";
        click class="newsletter"
      }

      failure {
        click id="close_rss"
      }

    }
RULEBODY


my $test_global = <<GLOBAL;
global {

     dataset public_timeline <-  "http://twitter.com/statuses/public_timeline.json";

     dataset cached_timeline <- "http://twitter.com/statuses/public_timeline.json" cachable;

     emit <<
var foobar = 4;    >>;

}
GLOBAL


my $test_global_bad = <<GLOBAL;
global {


     datastink cached_timeline <- "http://twitter.com/statuses/public_timeline.json" cachable
     emit <<
var foobar = 4;
     >>;

}
GLOBAL


my $test_json_global = <<JSON;
[{"source":"http://twitter.com/statuses/public_timeline.json","name":"public_timeline","type":"dataset","datatype":"JSON","cachable":0},{"source":"http://twitter.com/statuses/public_timeline.json","name":"cached_timeline","type":"dataset","datatype":"JSON","cachable":1},{"emit":"\\nvar foobar = 4;       "}]
JSON

my $test_dispatch = <<DISPATCH;
dispatch {

      domain "www.google.com"
      domain "search.yahoo.com"

      domain "www.google.com" -> "966337974"
      domain "google.com" -> "966337974"
      domain "www.circuitcity.com" -> "966337982"


}
DISPATCH

my $test_dispatch_bad = <<DISPATCH;
dispatch {

This should never work!

}
DISPATCH

my $test_json_dispatch = <<JSON;
[{"domain":"www.google.com","ruleset_id":null},{"domain":"search.yahoo.com","ruleset_id":null},{"domain":"www.google.com","ruleset_id":"966337974"},{"domain":"google.com","ruleset_id":"966337974"},{"domain":"www.circuitcity.com","ruleset_id":"966337982"}]
JSON

my $test_meta = <<META;
meta {
   description <<
Ruleset for testing something or other.
>>
   logging on
}
META

my $test_meta_bad = <<META;
meta {

 foobar is not a good entry for the meta stuff...

}
META

my $test_json_meta = <<JSON;
{"logging":"on","description":"\\nRuleset for testing something or other.\\n  "}
JSON

my $meta_key_bad = <<META;
meta {
    butt munch {
        qwb : "yes",
        sjf : "Probable"
    }
}
META

my $json;
my $ast;
my $east;
my $mech = Test::WWW::Mechanize->new();

#goto ENDY;

# check the API calls



Kynetx::Request::add_event_attr($my_req_info,'krl',$test_ruleset);

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "ruleset");

$ast = Kynetx::Json::jsonToAst_w($json);

$east = Kynetx::Json::jsonToAst_w($test_json_ruleset);

cmp_deeply($ast,
	       $east,
	       "Parsing a ruleset");


Kynetx::Request::add_event_attr($my_req_info,'krl', $test_ruleset_bad);
$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "ruleset");
diag $json;

contains_string($json,
	       'Invalid value [rule] found',
	       "Parsing ruleset with syntax error");



# test rule api
Kynetx::Request::add_event_attr($my_req_info,'krl', $test_rule);

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "rule");
$ast = Kynetx::Json::jsonToAst_w($json);
$east = Kynetx::Json::jsonToAst_w($test_json_rule);

cmp_deeply($ast,
    $east,
	"Parsing a rule");


Kynetx::Request::add_event_attr($my_req_info,'krl', $test_rule_bad);
#diag $my_req_info->{'krl'};

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "rule");

contains_string($json,
    'Parser Exception',
    "Parsing rule with syntax error");



Kynetx::Request::add_event_attr($my_req_info,'krl', $test_global);

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "global");

is_string_nows($json,
	       $test_json_global,
	       "Parsing global decls");

Kynetx::Request::add_event_attr($my_req_info,'krl', $test_global_bad);

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "global");

contains_string($json,
	       'Invalid value [datastink] found',
	       "Parsing global decls with syntax error");

Kynetx::Request::add_event_attr($my_req_info,'krl', $test_dispatch);

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "dispatch");

is_string_nows($json,
	       $test_json_dispatch,
	       "Parsing dispatch decls");


Kynetx::Request::add_event_attr($my_req_info,'krl', $test_dispatch_bad);
#diag $my_req_info->{'krl'};

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "dispatch");
#diag $json;

contains_string($json,
	       'error',
	       "Parsing dispatch decls with syntax error");


Kynetx::Request::add_event_attr($my_req_info,'krl', $test_meta);

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "meta");
#diag $json;

is_string_nows($json,
	       $test_json_meta,
	       "Parsing meta decls");



Kynetx::Request::add_event_attr($my_req_info,'krl', $test_meta_bad);
#diag $my_req_info->{'krl'};

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "meta");
#diag $json;

contains_string($json,
	       'error',
	       "Parsing meta decls with syntax error");

Kynetx::Request::add_event_attr($my_req_info,'krl', $meta_key_bad);
#diag $my_req_info->{'krl'};

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "meta");
#diag $json;

contains_string($json,
           'Found [butt] should have been key',
           "Parsing meta decls with syntax error");


# check the unparse API calls
my $krl;
Kynetx::Request::add_event_attr($my_req_info,'ast', $test_json_ruleset);

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "ruleset");

is_string_nows($krl,
	       $test_ruleset,
	       "Unparsing a ruleset");


Kynetx::Request::add_event_attr($my_req_info,'ast', $test_json_rule);

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "rule");

is_string_nows($krl,
	       $test_rule_body,
	       "Unparsing a rule");

Kynetx::Request::add_event_attr($my_req_info,'ast', $test_json_global);

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "global");

is_string_nows($krl,
	       $test_global,
	       "Unparsing a global");


Kynetx::Request::add_event_attr($my_req_info,'ast', $test_json_dispatch);

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "dispatch");

is_string_nows($krl,
	       $test_dispatch,
	       "Unparsing a dispatch");


Kynetx::Request::add_event_attr($my_req_info,'ast', $test_json_meta);

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "meta");

is_string_nows($krl,
	       $test_meta,
	       "Unparsing a meta");



# check the server now


my $skippable = $numtests - $nonskippable;

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$ruleset";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $skippable if (! $response->is_success);

    # test version function
    my $url_version_1 = "$dn/version/$ruleset";
#    diag "Testing console with $url_version_1";

    $mech->get_ok($url_version_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('KNS Version');

    $mech->content_like('/number\s+[\da-f]+/');

    my $url_version_2 = "$dn/version/$ruleset?flavor=json";
    #diag "Testing console with $url_version_2";

    $mech->get_ok($url_version_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/{"build_num"\s*:\s*"[\da-f]+/');

    # validate
    my $url_version_3 = "$dn/validate/$ruleset";
#    diag "Testing validate with $url_version_3";

    $mech->get_ok($url_version_3);
    $mech->field('rule',$test_ruleset);
    $mech->field('flavor', 'html');
    $mech->submit_form_ok();

    is($mech->content_type(), 'text/html');
    $mech->title_is('Validate KRL');
    $mech->content_contains('"ruleset_name" : "10"');

    $mech->back();
    $mech->field('rule',$test_ruleset);
    $mech->field('flavor', 'json');
    $mech->submit_form_ok();

    is($mech->content_type(), 'text/plain');
    $mech->content_contains('"ruleset_name" : "10"');

    # jsontokrl
    my $url_version_4 = "$dn/jsontokrl/$ruleset";
#    diag "Testing validate with $url_version_4";

    $mech->get_ok($url_version_4);
    $mech->field('json',$test_json_ruleset);
    $mech->field('type', 'ruleset');
    $mech->submit_form_ok();

    is($mech->content_type(), 'text/html');
    $mech->content_contains('ruleset 10 {');

    $mech->back();
    $mech->field('json',$test_json_rule);
    $mech->field('type', 'bodyonly');
    $mech->submit_form_ok();

    is($mech->content_type(), 'text/html');
    $mech->content_contains('select using "/identity-policy/" setting ()');


    # parse/ruleset
    my $url_version_5 = "$dn/parse/ruleset";
#    diag "Testing $url_version_5";

    $mech->post_ok($url_version_5, ['krl'=> $test_ruleset]);

    is($mech->content_type(), 'text/plain');
    $ast = Kynetx::Json::jsonToAst_w($mech->response()->content);
    $east = Kynetx::Json::jsonToAst_w($test_json_ruleset);
    cmp_deeply($ast,$east,"Mech test U5 ruleset");

    # parse/rule
    my $url_version_6 = "$dn/parse/rule";
#    diag "Testing $url_version_6";

    $mech->post_ok($url_version_6, ['krl'=> $test_rule]);

    is($mech->content_type(), 'text/plain');
    $ast = Kynetx::Json::jsonToAst_w($mech->response()->content);
    $east = Kynetx::Json::jsonToAst_w($test_json_rule);
    cmp_deeply($ast,$east,"Mech test U6 rule");


    # parse/global
    my $url_version_7 = "$dn/parse/global";
#    diag "Testing $url_version_7";

    $mech->post_ok($url_version_7, ['krl'=> $test_global]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_json_global);


    # parse/global (bad)
    my $url_version_7a = "$dn/parse/global";
#    diag "Testing $url_version_7a";

    $mech->post_ok($url_version_7a, ['krl'=> $test_global_bad]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,'{"error":["line4:15Invalidvalue[datastink]foundshouldhavebeenoneof[dataset,datasource]"]}');

    # parse/dispatch
    my $url_version_71 = "$dn/parse/dispatch";
#    diag "Testing $url_version_71";

    $mech->post_ok($url_version_71, ['krl'=> $test_dispatch]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_json_dispatch);


    # parse/dispatch
    my $url_version_71a = "$dn/parse/dispatch";
#    diag "Testing $url_version_71a";

    $mech->post_ok($url_version_71a, ['krl'=> $test_dispatch_bad]);

    is($mech->content_type(), 'text/plain');
    contains_string($mech->response()->content,
		    'error');



    # parse/meta
    my $url_version_72 = "$dn/parse/meta";
#    diag "Testing $url_version_72";

    $mech->post_ok($url_version_72, ['krl'=> $test_meta]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_json_meta);


    # parse/ruleset
    my $url_version_8 = "$dn/unparse/ruleset";
#    diag "Testing $url_version_8";

    $mech->post_ok($url_version_8, ['ast'=> $test_json_ruleset]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_ruleset);


    # unparse/rule
    my $url_version_9 = "$dn/unparse/rule";
#    diag "Testing $url_version_9";

    $mech->post_ok($url_version_9, ['ast'=> $test_json_rule]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_rule_body);


    # unparse/global
    my $url_version_10 = "$dn/unparse/global";
#    diag "Testing $url_version_10";

    $mech->post_ok($url_version_10, ['ast'=> $test_json_global]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_global);


    # unparse/dispatch
    my $url_version_11 = "$dn/unparse/dispatch";
#    diag "Testing $url_version_11";

    $mech->post_ok($url_version_11, ['ast'=> $test_json_dispatch]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_dispatch);


    # unparse/meta
    my $url_version_12 = "$dn/unparse/meta";
#    diag "Testing $url_version_12";

    $mech->post_ok($url_version_12, ['ast'=> $test_json_meta]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_meta);


    # unparse/meta
    my $url_version_13 = "$dn/flushdata/foo";
#    diag "Testing $url_version_13";

    $mech->get_ok($url_version_13);

    is($mech->content_type(), 'text/html');
    $mech->content_contains("<span id=\"foo\">");

    my $now = time();

    $memd->set("test1", $now);

    is($memd->get("test1"), $now, "Did it get stored?");

ENDY:

    my $url_version_14 = "$dn/flushdata/test1";
#    diag "Testing $url_version_14";

    $mech->get_ok($url_version_14);

    is($mech->content_type(), 'text/html');
    $mech->content_like(qr/<span id=\"requestid\">.*?<\/span>/);



}


1;




