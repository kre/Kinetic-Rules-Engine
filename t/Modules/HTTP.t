#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;
use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


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
my $test_site = "http://httpbin.org";
my $stest_site = "https://httpbin.org";
#goto ENDY;
$krl_src = <<_KRL_;
// Everything but the URI should be ignored in an http delete
http:patch("http://www.example.com") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Content-Type" : "text/plain"
		} and
		credentials = {
			"netloc" : "httpbin.org:80",
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
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
ok($result->{'content'} eq '', "Content undefined");
ok($result->{'status_code'} eq '302', "Status code Found(?)");
$test_count += 2;

#goto ENDY;



$krl_src = <<_KRL_;
// Everything but the URI should be ignored in an http delete
http:delete("$test_site/delete") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Content-Type" : "text/plain"
		} and
		credentials = {
			"netloc" : "httpbin.org:80",
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
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
ok($result->{'content'} =~ m/data\": \"\"/, "Content undefined");
ok($result->{'status_code'} eq '200', "Status code defined");
$test_count += 2;

#goto ENDY;


$krl_src = <<_KRL_;
http:put("$test_site/put") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Content-Type" : "text/plain"
		} and
		credentials = {
			"netloc" : "httpbin.org:80",
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
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
ok(int($result->{'content_length'}) > 0, "Content length defined");
ok($result->{'status_code'} eq '200', "Status code defined");
ok($result->{'content'} =~ m/data\": \"foon=45/, "Text/Plain comes back as data");
$test_count += 3;


$krl_src = <<_KRL_;
http:put("$test_site/put") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Accept" : "text/plain",
			"Cache-Control" : "no-cache"
		} and
		credentials = {
			"netloc" : "httpbin.org:80",
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
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
ok(int($result->{'content_length'}) > 0, "Content length defined");
ok($result->{'status_code'} eq '200', "Status code defined");
ok(defined $result->{'content'}, "Default Form encoding comes back as form");
$test_count += 3;

#goto ENDY;


$krl_src = <<_KRL_;
http:head("$test_site/get") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Accept" : "text/plain",
			"Cache-Control" : "no-cache"
		} and
		credentials = {
			"netloc" : "httpbin.org:80",
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
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
ok($result->{'content_length'} > 0, "Content length defined");
ok($result->{'status_code'} eq '200', "Status code defined");
ok($result->{'content'} eq '', "No content back from HEAD request");
$test_count += 3;

#goto ENDY;



$krl_src = <<_KRL_;
http:get("$test_site/get") setting(r) 
	with 
		params = {"foon": 45}  and
		headers = {
			"Accept" : "text/plain",
			"Cache-Control" : "no-cache"
		} and
		credentials = {
			"netloc" : "httpbin.org:80",
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
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
ok($result->{'content_length'} > 0, "Content length defined");
ok($result->{'status_code'} eq '200', "Status code defined");
ok($result->{'content'} =~ m/Cache-Control\": \"no-cache/, "Content back from httpbin includes request headers");
$test_count += 3;



# set variable and raise event
$krl_src = <<_KRL_;
http:post("http://epfactory.kynetx.com:3098/1/bookmarklet/aaa/dev") setting(r)
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev"
                   } and
          autoraise = "example";
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;


$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
is($result->{'label'}, "example", "Label is example");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok(defined $result->{'content'}, "Content defined");
$test_count += 4;

is($my_req_info->{'label'}, 'example', "label is example");
ok(defined $my_req_info->{'content_length'}, "Content length defined");
ok(defined $my_req_info->{'status_code'}, "Status code defined");
ok(defined $my_req_info->{'content'}, "Content defined");
$test_count += 4;

# set variable but don't raise event
$krl_src = <<_KRL_;
http:post("http://epfactory.kynetx.com:3098/1/bookmarklet/aaa/dev") setting(r)
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev"
                   };
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);

isnt($result->{'label'}, "example", "label is NOT example"); # 
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok(defined $result->{'content'}, "Content defined");
$test_count += 4;

# shouldn't be in the req_info because no event fired
ok(!defined $my_req_info->{'content_length'}, "Content length defined");
ok(!defined $my_req_info->{'status_code'}, "Status code defined");
ok(!defined $my_req_info->{'content'}, "Content defined");
$test_count += 3;

# now raise event, but don't set variable
$krl_src = <<_KRL_;
http:post("http://epfactory.kynetx.com:3098/1/bookmarklet/aaa/dev")
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev"
                   } and
          autoraise = "example";
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

ok(! defined lookup_rule_env('r',$rule_env), "r is NOT defined");
$test_count += 1;

is($my_req_info->{'label'}, 'example', "label is example");
ok(defined $my_req_info->{'content_length'}, "Content length defined");
ok(defined $my_req_info->{'status_code'}, "Status code defined");
ok(defined $my_req_info->{'content'}, "Content defined");
$test_count += 4;

# with headers
$krl_src = <<_KRL_;
http:post("http://www.postbin.org/1g00pes")
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev",
                    "minnie" : "1.0"
                   } and
          autoraise = "example2" and 
          headers = {"user-agent": "flipper",
                     "X-proto": "foogle"
                    };
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

is($my_req_info->{'label'}, 'example2', "label is example2");
ok(defined $my_req_info->{'content_length'}, "Content length defined");
ok(defined $my_req_info->{'status_code'}, "Status code defined");
ok(defined $my_req_info->{'content'}, "Content defined");
$test_count += 4;

# with headers
$krl_src = <<_KRL_;
http:post("http://www.postbin.org/1g00pes")
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev",
                    "minnie" : "1.0"
                   } and
          autoraise = "example2" and 
          headers = {"user-agent": "flipper",
                     "X-proto": "foogle"
                    };
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

is($my_req_info->{'label'}, 'example2', "label is example2"); 
ok(defined $my_req_info->{'content_length'}, "Content length defined");
ok(defined $my_req_info->{'status_code'}, "Status code defined");
ok(defined $my_req_info->{'content'}, "Content defined");
$test_count += 4;
 
# try GET
$krl_src = <<_KRL_;
http:get("http://epfactory.kynetx.com:3098/1/bookmarklet/aaa/dev") setting(r)
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev"
                   } and
          autoraise = "example";
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
is($result->{'label'}, "example", "rule_env: Label is example");
ok(defined $result->{'content_length'}, "rule_env: Content length defined");
ok(defined $result->{'status_code'}, "rule_env: Status code defined");
ok(defined $result->{'content'}, "rule_env: Content defined");
$test_count += 4;

is($my_req_info->{'label'}, 'example', "req_info: label is example");
ok(defined $my_req_info->{'content_length'}, "req_info: Content length defined");
ok(defined $my_req_info->{'status_code'}, "req_info: Status code defined");
ok(defined $my_req_info->{'content'}, "req_info: Content defined");
$test_count += 4;


# test the get function (expression)
$krl_src = <<_KRL_;
r = http:get("http://epfactory.kynetx.com:3098/1/bookmarklet/aaa/dev",
	       {"init_host": "qa.kobj.net",
		"eval_host": "qa.kobj.net",
		"callback_host": "qa.kobj.net",
		"contents": "compiled",
		"format": "json",
		"version": "dev"
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

	
#diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);

is($v, "r", "Get right lhs");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok(defined $result->{'content'}, "Content defined");
$test_count += 4;



# with headers
$krl_src = <<_KRL_;
http:post("http://www.postbin.org/1g00pes")
     with params = {"init_host": "qa.kobj.net",
		    "eval_host": "qa.kobj.net",
		    "callback_host": "qa.kobj.net",
		    "contents": "compiled",
		    "format": "json",
		    "version": "dev",
                    "minnie" : "1.0"
                   } and
          autoraise = "example2" and 
          headers = {"user-agent": "flipper",
                     "X-proto": "foogle"
                    } and
          response_headers = ["flipper"];
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one

# start with a fresh $req_info and $rule_env
$my_req_info = Kynetx::Test::gen_req_info($rid);
$rule_env = Kynetx::Test::gen_rule_env();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

is($my_req_info->{'label'}, 'example2', "label is example2"); 
ok(defined $my_req_info->{'content_length'}, "Content length defined");
ok(defined $my_req_info->{'status_code'}, "Status code defined");
ok(defined $my_req_info->{'content'}, "Content defined");
$test_count += 4;

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

$krl_src = <<_KRL_;
r = http:post("$test_site/post",
	       {
			"credentials" : {
				"netloc" : "httpbin.org:80",
				"realm" : "Fake Realm",
				"username" : "qwerty",
				"password" : "vorpal"	
			},
			"params" : {"ffoosh": "Flavor enhancer"},
			"headers" : {"Accept" : "text/plain"},
			"response_headers" : ["Connection","Accept"]	       	
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

	
#diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
#$logger->debug("Content: ", sub {Dumper($result->{'content'})});

is($v, "r", "Get right lhs");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok($result->{'content'} =~ m/ffoosh/, "Content defined");
$test_count += 4;

$krl_src = <<_KRL_;
r = http:put("$test_site/put",
	       {
			"credentials" : {
				"netloc" : "httpbin.org:80",
				"realm" : "Fake Realm",
				"username" : "qwerty",
				"password" : "vorpal"	
			},
			"params" : {"ffoosh": "Flavor enhancer"},
			"headers" : {"Accept" : "text/plain"},
			"response_headers" : ["Connection","Accept"]	       	
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

	
#diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
#$logger->debug("Content: ", sub {Dumper($result->{'content'})});

is($v, "r", "Get right lhs");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok($result->{'content'} =~ m/ffoosh/, "Content defined");
$test_count += 4;

$krl_src = <<_KRL_;
r = http:head("$test_site/get",
	       {
			"credentials" : {
				"netloc" : "httpbin.org:80",
				"realm" : "Fake Realm",
				"username" : "qwerty",
				"password" : "vorpal"	
			},
			"params" : {"ffoosh": "Flavor enhancer"},
			"headers" : {"Accept" : "text/plain"},
			"response_headers" : ["Connection","Accept"]	       	
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

	
#diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
#$logger->debug("Content: ", sub {Dumper($result->{'content'})});

is($v, "r", "Get right lhs");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok($result->{'content'} eq '', "No content returned for HEAD");
$test_count += 4;

$krl_src = <<_KRL_;
r = http:delete("$test_site/delete",
	       {
			"credentials" : {
				"netloc" : "httpbin.org:80",
				"realm" : "Fake Realm",
				"username" : "qwerty",
				"password" : "vorpal"	
			},
			"params" : {"ffoosh": "Flavor enhancer"},
			"headers" : {"Accept" : "text/plain"},
			"response_headers" : ["Connection","Accept"]	       	
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

	
#diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
#$logger->debug("Content: ", sub {Dumper($result->{'content'})});

is($v, "r", "Get right lhs");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok($result->{'content'} =~ m/data\": \"\"/, "No data returned for DELETE");
$test_count += 4;

ENDY:
$krl_src = <<_KRL_;
r = http:patch("http://www.example.com",
	       {
			"credentials" : {
				"netloc" : "httpbin.org:80",
				"realm" : "Fake Realm",
				"username" : "qwerty",
				"password" : "vorpal"	
			},
			"params" : {"ffoosh": "Flavor enhancer"},
			"headers" : {"Accept" : "text/plain"},
			"response_headers" : ["Connection","Accept"]	       	
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

	
#diag($krl->{'rhs'}->{'predicate'}  . "($v) --> " . Dumper $result);
#$logger->debug("Content: ", sub {Dumper($result->{'content'})});

is($v, "r", "Get right lhs");
ok(defined $result->{'content_length'}, "Content length defined");
ok(defined $result->{'status_code'}, "Status code defined");
ok($result->{'content'} eq '', "No data returned for PATCH");
$test_count += 4;


done_testing($test_count);



1;


