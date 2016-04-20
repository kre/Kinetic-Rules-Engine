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
use warnings;
use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use JSON::XS;
use LWP::Simple;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Modules::HTTP qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Response qw/:all/;


use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();


my $preds = Kynetx::Modules::HTTP::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;

my($config, $mods, $args, $krl, $krl_src, $js, $result, $v);
my $postbin_url = "http://www.postbin.org/1g00pes";

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
]);

# http://epfactory.kynetx.com:3098/1/bookmarklet/aaa/dev?init_host=qa.kobj.net&eval_host=qa.kobj.net&callback_host=qa.kobj.net&contents=compiled&format=json&version=dev

# most basic requests
# It looks like www.requestb.in was dropped in favor of requestb.in
my $test_site_url = "http://requestb.in";
my $stest_site_url = "https://requestb.in";

# create a bin
Kynetx::Modules::HTTP::do_post($my_req_info, $rule_env, $session, {}, {}, ["$test_site_url/api/v1/bins"], ["this_bin"] );

my $bin_resp = Kynetx::Environments::lookup_rule_env("this_bin", $rule_env);

die "Bad response from $test_site_url" unless $bin_resp->{"status_code"} eq "200";

my $bin = decode_json($bin_resp->{"content"});
#diag Dumper $bin;

my $test_site = $test_site_url."/".$bin->{"name"};
my $requests_url = "$test_site_url/api/v1/bins/".$bin->{"name"}."/requests";
my ($response, $expected);

#goto ENDY;

my $dd = Kynetx::Response->create_directive_doc($my_req_info->{'eid'});

sub check_http_response {
  my ($rule_env, $rubric, $diag) = @_;

  $result = lookup_rule_env('r',$rule_env);
  #diag Dumper $result;


  # basic stuff
  ok($result->{'status_code'} eq '200', "Status code defined");

  my $tests = 1;

  $response = decode_json(get $requests_url)->[0];
  diag Dumper $response if $diag;
  foreach my $k (keys %{$rubric}) {

      my $description = "Checking $k";

      my $decoded_resp = $response->{$k};
      if (ref $rubric->{$k} eq "ARRAY" || ref $rubric->{$k} eq "HASH") {

	  if (not (ref $response->{$k} eq "HASH" || ref $response->{$k})) {
	      $decoded_resp = eval {decode_json($response->{$k})};
	      if ($@) {
		  $decoded_resp = $response->{$k};
	      }
	  }
#	  diag "checking against ", Dumper $decoded_resp;
	  foreach my $rub (keys %{$rubric->{$k}}) {
	      is_deeply($decoded_resp->{$rub}, $rubric->{$k}->{$rub}, $description."->$rub");
	      $tests++;
	  }
      } else {
	  is($decoded_resp, $rubric->{$k}, $description);
	  $tests++;
      }


  }
  return $tests;
}


# httpbin is returning a 501 for PATCH requests

#$krl_src = <<_KRL_;
#// Everything but the URI should be ignored in an http delete
#http:patch("http://www.example.com") setting(r) 
#	with 
#		params = {"foon": 45}  and
#		headers = {
#			"Content-Type" : "text/plain"
#		} and
#		credentials = {
#			"netloc" : "requestb.in:80",
#			"realm" : "Fake Realm",
#			"username" : "foosh",
#			"password" : "qwerty"
#			
#		} and
#		response_headers = ["Connection","Accept"]
#	  
#_KRL_
#
#$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
##diag Dumper $krl;
#
#
#$js = Kynetx::Actions::build_one_action(
#	    $krl,
#	    $my_req_info, 
#	    $dd,
#	    $rule_env,
#	    $session,
#	    'callback23',
#	    'dummy_name');
#
#$result = lookup_rule_env('r',$rule_env);
#ok($result->{'content'} eq '', "Content undefined");
#ok($result->{'status_code'} eq '302', "Status code Found(?)");
#$test_count += 2;


$krl_src = <<_KRL_;
// Everything but the URI should be ignored in an http delete
http:delete("$test_site") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Content-Type" : "text/plain"
		} and
		credentials = {
			"netloc" : "requestb.in:80",
			"realm" : "Fake Realm",
			"username" : "foosh",
			"password" : "qwerty"
			
		} and
		response_headers = ["Connection","Accept"]
	  
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$expected = {"method" => "DELETE",
	    };

$test_count += check_http_response($rule_env, $expected );


$krl_src = <<_KRL_;
http:put("$test_site") setting(r) 
	with 
		body = "{'foo': 45,
                         'bar': true
                        }"  and
		headers = {
			"Content-Type" : "text/plain"
		} and
		credentials = {
			"netloc" : "requestb.in:80",
			"realm" : "Fake Realm",
			"username" : "foosh",
			"password" : "qwerty"
			
		} and
		response_headers = ["Connection","Accept"]
	  
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');


$expected = {"method" => "PUT",
	    };

$test_count += check_http_response($rule_env, $expected );


#diag "######################## PUT ########################";
$krl_src = <<_KRL_;
http:put("$test_site") setting(r) 
	with 
		params = {"foon": 45, "bar": "hey"}  and
		headers = {
			"Accept" : "text/plain",
			"Cache-Control" : "no-cache",
                        "Content-Type" : "application/json"
		} and
		credentials = {
			"netloc" : "requestb.in:80",
			"realm" : "Fake Realm",
			"username" : "foosh",
			"password" : "qwerty"
			
		} and
		response_headers = ["Connection","Accept"]
	  
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;


$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');


$expected = {"method" => "PUT",
	     "body" => {"foon" => 45, "bar" => "hey"},
	     "headers" => { "Accept" => "text/plain"}
	    };

$test_count += check_http_response($rule_env, $expected, 0 );


#goto ENDY;


$krl_src = <<_KRL_;
http:head("$test_site") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Accept" : "text/plain",
			"Cache-Control" : "no-cache"
		} and
		credentials = {
			"netloc" : "requestb.in:80",
			"realm" : "Fake Realm",
			"username" : "foosh",
			"password" : "qwerty"
			
		} and
		response_headers = ["Connection","Accept"]
	  
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;


$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$expected = {"method" => "HEAD",
	     "query_string" => {"foon" => ['45']},
	     "headers" => { "Accept" => "text/plain"}
	    };

$test_count += check_http_response($rule_env, $expected, 0 );


#goto ENDY;



$krl_src = <<_KRL_;
http:get("$test_site") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Accept" : "text/plain",
			"Cache-Control" : "no-cache"
		} and
		credentials = {
			"netloc" : "requestb.in:80",
			"realm" : "Fake Realm",
			"username" : "foosh",
			"password" : "qwerty"
			
		} and
		response_headers = ["Connection","Accept"]
	  
_KRL_


$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;


$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');


$expected = {"method" => "GET",
	     "query_string" => {"foon" => ['45']},
	     "headers" => { "Accept" => "text/plain",
			    "Cache-Control" => "no-cache"
			  }
	    };

$test_count += check_http_response($rule_env, $expected, 0 );


# test the get function (expression) with a hash

my $credentials = {
	"netloc" => "rulesetmanager.kobj.net:443",
	"realm" => "KynetxRulesetManager",
	"username" => "kynetx",
	"password" => "fart95"
};
my $params = {
	"init_host"=> "qa.kobj.net",
	"eval_host"=> "qa.kobj.net",
	"callback_host"=> "qa.kobj.net",
	"contents"=> "compiled",
	"format"=> "json",
	"version"=> "dev"
};
my $uri = "https://rulesetmanager.kobj.net/ruleset/source/cs_test/prod/krl";
my $headers = {"X-proto" => "flipper"};
my $rheaders = ["flipper"];
my $opts = {"headers" => $headers,
	"credentials" => $credentials,
	"params" => $params,
	"response_headers" => $rheaders
};
$krl_src = <<_KRL_;
r = http:get("$uri",{
	"credentials" : {
		"netloc" : "rulesetmanager.kobj.net:443",
		"realm" : "KynetxRulesetManager",
		"username" : "kynetx",
		"password" : "fart95"	
	}, 
	"params" : {"foo":"bar"},
	"headers" : {"Upgrade": "SHTTP/1.3"},
	"response_headers":["x-runtime","client-peer","x-powered_by"]
});
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);

#diag(Dumper($krl));

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

($v,$result) = Kynetx::Expressions::eval_decl(
    $my_req_info,
    $rule_env,
    $rule_name,
    $session,
    $krl
    );


is($v, "r", "Get right lhs");
#$logger->debug("Result: ", sub {Dumper($result)});
like($result->{'content'}, qr/CS Test 1/, "Correct ruleset received");
like($result->{'x-runtime'}, qr/0\.0\d+/, "x-runtime is there");
$test_count += 3;


#### requestb.in doesn't store results

# $krl_src = <<_KRL_;
# r = http:post("$test_site",
# 	       {
# 			"body" : {"key1": "value1"},
# 			"headers" : {"content-type" : "application/json"}	       	
# 	       });
# _KRL_
# $krl = Kynetx::Parser::parse_decl($krl_src);

# #diag(Dumper($krl));

# # start with a fresh $req_info and $rule_env
# $my_req_info = Kynetx::Test::gen_req_info($rid);
# $rule_env = Kynetx::Test::gen_rule_env();

# ($v,$result) = Kynetx::Expressions::eval_decl(
#     $my_req_info,
#     $rule_env,
#     $rule_name,
#     $session,
#     $krl
#     );

	
# #diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
# #$logger->debug("Content: ", sub {Dumper($result->{'content'})});

# is($v, "r", "Get right lhs");
# ok(defined $result->{'content_length'}, "Content length defined");
# ok(defined $result->{'status_code'}, "Status code defined");
# ok($result->{'content'} =~ m/value1/, "Content defined");
# $test_count += 4;


# $krl_src = <<_KRL_;
# r = http:put("$test_site/put",
# 	       {
# 			"credentials" : {
# 				"netloc" : "requestb.in:80",
# 				"realm" : "Fake Realm",
# 				"username" : "qwerty",
# 				"password" : "vorpal"	
# 			},
# 			"params" : {"ffoosh": "Flavor enhancer"},
# 			"headers" : {"Accept" : "text/plain"},
# 			"response_headers" : ["Connection","Accept"]	       	
# 	       });
# _KRL_

# $krl = Kynetx::Parser::parse_decl($krl_src);

# #diag(Dumper($krl));

# # start with a fresh $req_info and $rule_env
# $my_req_info = Kynetx::Test::gen_req_info($rid);
# $rule_env = Kynetx::Test::gen_rule_env();

# ($v,$result) = Kynetx::Expressions::eval_decl(
#     $my_req_info,
#     $rule_env,
#     $rule_name,
#     $session,
#     $krl
#     );

	
# #diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
# #$logger->debug("Content: ", sub {Dumper($result->{'content'})});

# is($v, "r", "Get right lhs");
# ok(defined $result->{'content_length'}, "Content length defined");
# ok(defined $result->{'status_code'}, "Status code defined");
# ok($result->{'content'} =~ m/ffoosh/, "Content defined");
# $test_count += 4;

# $krl_src = <<_KRL_;
# r = http:put("$test_site/put",
# 	       {
# 			"credentials" : {
# 				"netloc" : "requestb.in:80",
# 				"realm" : "Fake Realm",
# 				"username" : "qwerty",
# 				"password" : "vorpal"	
# 			},
# 			"body" : "Some formatted data",
# 			"headers" : {"Content-Type" : "text/plain"},
# 			"response_headers" : ["Connection","Accept"]	       	
# 	       });
# _KRL_

# $krl = Kynetx::Parser::parse_decl($krl_src);

# #diag(Dumper($krl));

# # start with a fresh $req_info and $rule_env
# $my_req_info = Kynetx::Test::gen_req_info($rid);
# $rule_env = Kynetx::Test::gen_rule_env();

# ($v,$result) = Kynetx::Expressions::eval_decl(
#     $my_req_info,
#     $rule_env,
#     $rule_name,
#     $session,
#     $krl
#     );

	
# #diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
# #$logger->debug("Content: ", sub {Dumper($result->{'content'})});

# is($v, "r", "Get right lhs");
# ok(defined $result->{'content_length'}, "Content length defined");
# ok(defined $result->{'status_code'}, "Status code defined");
# ok($result->{'content'} =~ m/Some formatted/, "Content defined");
# $test_count += 4;

# $krl_src = <<_KRL_;
# r = http:head("$test_site/get",
# 	       {
# 			"credentials" : {
# 				"netloc" : "requestb.in:80",
# 				"realm" : "Fake Realm",
# 				"username" : "qwerty",
# 				"password" : "vorpal"	
# 			},
# 			"params" : {"ffoosh": "Flavor enhancer"},
# 			"headers" : {"Accept" : "text/plain"},
# 			"response_headers" : ["Connection","Accept"]	       	
# 	       });
# _KRL_

# $krl = Kynetx::Parser::parse_decl($krl_src);

# #diag(Dumper($krl));

# # start with a fresh $req_info and $rule_env
# $my_req_info = Kynetx::Test::gen_req_info($rid);
# $rule_env = Kynetx::Test::gen_rule_env();

# ($v,$result) = Kynetx::Expressions::eval_decl(
#     $my_req_info,
#     $rule_env,
#     $rule_name,
#     $session,
#     $krl
#     );

	
# #diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
# #$logger->debug("Content: ", sub {Dumper($result->{'content'})});

# is($v, "r", "Get right lhs");
# ok(defined $result->{'content_length'}, "Content length defined");
# ok(defined $result->{'status_code'}, "Status code defined");
# ok($result->{'content'} eq '', "No content returned for HEAD");
# $test_count += 4;

# $krl_src = <<_KRL_;
# r = http:delete("$test_site/delete",
# 	       {
# 			"credentials" : {
# 				"netloc" : "requestb.in:80",
# 				"realm" : "Fake Realm",
# 				"username" : "qwerty",
# 				"password" : "vorpal"	
# 			},
# 			"params" : {"ffoosh": "Flavor enhancer"},
# 			"headers" : {"Accept" : "text/plain"},
# 			"response_headers" : ["Connection","Accept"]	       	
# 	       });
# _KRL_

# $krl = Kynetx::Parser::parse_decl($krl_src);

# #diag(Dumper($krl));

# # start with a fresh $req_info and $rule_env
# $my_req_info = Kynetx::Test::gen_req_info($rid);
# $rule_env = Kynetx::Test::gen_rule_env();

# ($v,$result) = Kynetx::Expressions::eval_decl(
#     $my_req_info,
#     $rule_env,
#     $rule_name,
#     $session,
#     $krl
#     );

	
# #diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
# #$logger->debug("Content: ", sub {Dumper($result->{'content'})});

# is($v, "r", "Get right lhs");
# ok(defined $result->{'content_length'}, "Content length defined");
# ok(defined $result->{'status_code'}, "Status code defined");
# ok($result->{'content'} =~ m/data\": \"\"/, "No data returned for DELETE");
# $test_count += 4;


ENDY:

done_testing($test_count);



1;


