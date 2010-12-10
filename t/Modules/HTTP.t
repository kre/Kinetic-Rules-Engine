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
http:post("http://127.0.0.1/widgets/printenv.pl")
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

#is($my_req_info->{'label'}, 'example2', "label is example2"); 
#ok(defined $my_req_info->{'content_length'}, "Content length defined");
#ok(defined $my_req_info->{'status_code'}, "Status code defined");
#ok(defined $my_req_info->{'content'}, "Content defined");
#$test_count += 4;
# 


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
http:post("http://127.0.0.1/widgets/printenv.pl")
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

#is($my_req_info->{'label'}, 'example2', "label is example2"); 
#ok(defined $my_req_info->{'content_length'}, "Content length defined");
#ok(defined $my_req_info->{'status_code'}, "Status code defined");
#ok(defined $my_req_info->{'content'}, "Content defined");
#$test_count += 4;
# 


#diag Dumper $my_req_info;
#diag Dumper $rule_env;


# test the get function (expression)
$krl_src = <<_KRL_;
r = http:get("http://127.0.0.1/widgets/printenv.pl",
	       {"init_host": "qa.kobj.net",
		"eval_host": "qa.kobj.net",
		"callback_host": "qa.kobj.net",
		"contents": "compiled",
		"format": "json",
		"version": "dev"
	       },
               {"X-proto": "flipper"},
               ["flipper"]);
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
like($result->{'flipper'}, qr/hello world/, "Flipper is there");
like($result->{'content'}, qr/HTTP_X_PROTO/, "x-proto is there");
$test_count += 3;



# with body, not encoded
$krl_src = <<_KRL_;
http:post("http://127.0.0.1/widgets/printenv.pl")
     with body = "<?xml encoding='UTF-8'?><feed version='0.3'></feed>" and
          autoraise = "example2" and 
          headers = {"content-type": "application/xml"
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

#diag Dumper $my_req_info;
like($my_req_info->{'content'}, qr/CONTENT_LENGTH="\d+"/, "Content length there");
like($my_req_info->{'content'}, qr/CONTENT_TYPE="application\/xml"/, "Content length there");
$test_count += 2;
# 


done_testing($test_count);



1;


