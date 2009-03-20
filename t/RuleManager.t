#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;

use LWP::UserAgent;

use Apache2::Const;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::FakeReq qw/:all/;
use Kynetx::Test qw/:all/;
use Kynetx::RuleManager qw/:all/;

my $numtests = 46;
my $nonskippable = 6;
plan tests => $numtests;

my $my_req_info;

my $r = new Kynetx::FakeReq();


my $dn = "http://127.0.0.1/manage";

my $ruleset = "cs_test";

my $test_ruleset = <<RULESET;
ruleset 10 {
  rule test_choose is inactive {
    select using "/identity-policy/" setting ()

    pre {
    }

    if daytime() then 
    choose {
        first_rule_name: 
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name: 
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


my $test_json_ruleset = <<JSON;
{"global":[],"dispatch":[],"ruleset_name":"10","rules":[{"cond":{"predicate":"daytime","args":[],"type":"simple"},"blocktype":"choose","actions":[{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_1.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"gift certificate","type":"str"},{"val":"yellow","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"30","type":"num"},"name":"delay"}]},"label":"first_rule_name"},{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_2.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"discount","type":"str"},{"val":"blue","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"true","type":"bool"},"name":"draggable"}]},"label":"second_rule_name"}],"post":null,"pre":[],"name":"test_choose","emit":null,"state":"inactive","callbacks":{"success":[{"attribute":"id","value":"rssfeed","type":"click"},{"attribute":"class","value":"newsletter","type":"click"}],"failure":[{"attribute":"id","value":"close_rss","type":"click"}]},"pagetype":{"pattern":"/identity-policy/","vars":[]}}],"meta":{}}
JSON

my $test_json_rule = <<JSON;
{"cond":{"predicate":"daytime","args":[],"type":"simple"},"blocktype":"choose","actions":[{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_1.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"gift certificate","type":"str"},{"val":"yellow","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"30","type":"num"},"name":"delay"}]},"label":"first_rule_name"},{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_2.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"discount","type":"str"},{"val":"blue","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"true","type":"bool"},"name":"draggable"}]},"label":"second_rule_name"}],"post":null,"pre":[],"name":"test_choose","emit":null,"state":"inactive","callbacks":{"success":[{"attribute":"id","value":"rssfeed","type":"click"},{"attribute":"class","value":"newsletter","type":"click"}],"failure":[{"attribute":"id","value":"close_rss","type":"click"}]},"pagetype":{"pattern":"/identity-policy/","vars":[]}}
JSON

my $test_rule = <<RULE;
rule test_choose is inactive {
    select using "/identity-policy/" setting ()

    pre {
    }

    if daytime() then 
    choose {
        first_rule_name: 
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name: 
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

my $test_rule_body = <<RULEBODY;
    select using "/identity-policy/" setting ()

    pre {
    }

    if daytime() then 
    choose {
        first_rule_name: 
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name: 
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
var foobar = 4;
     >>;

}
GLOBAL

my $test_json_global = <<JSON;
[{"source":"http://twitter.com/statuses/public_timeline.json","name":"public_timeline","cachable":0},{"source":"http://twitter.com/statuses/public_timeline.json","name":"cached_timeline","cachable":1},{"emit":"var foobar = 4;  "}]
JSON

my $json;

# check the API calls
$my_req_info->{'krl'} = $test_ruleset;

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "ruleset");

is_string_nows($json, 
	       $test_json_ruleset,
	       "Parsing a ruleset");

$my_req_info->{'krl'} = $test_rule;

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "rule");

is_string_nows($json, 
	       $test_json_rule,
	       "Parsing a rule");


$my_req_info->{'krl'} = $test_global;

$json = Kynetx::RuleManager::parse_api($my_req_info, "parse", "global");

is_string_nows($json, 
	       $test_json_global,
	       "Parsing global decls");


# check the unparse API calls
my $krl;
$my_req_info->{'ast'} = $test_json_ruleset;

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "ruleset");

is_string_nows($krl, 
	       $test_ruleset,
	       "Unparsing a ruleset");

$my_req_info->{'ast'} = $test_json_rule;

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "rule");

is_string_nows($krl, 
	       $test_rule_body,
	       "Unparsing a rule");

$my_req_info->{'ast'} = $test_json_global;

$krl = Kynetx::RuleManager::unparse_api($my_req_info, "unparse", "global");

is_string_nows($krl, 
	       $test_global,
	       "Unparsing a global");

#diag $json;



# check the server now

my $mech = Test::WWW::Mechanize->new();

my $skippable = $numtests - $nonskippable;

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$ruleset";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $skippable if (! $response->is_success);

    # test version function
    my $url_version_1 = "$dn/version/$ruleset";
    #diag "Testing console with $url_version_1";

    $mech->get_ok($url_version_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('KNS Version');

    $mech->content_like('/number\s+\d+/');

    my $url_version_2 = "$dn/version/$ruleset?flavor=json";
    #diag "Testing console with $url_version_2";

    $mech->get_ok($url_version_2);
    is($mech->content_type(), 'text/plain');

    $mech->content_like('/{"build_num"\s*:\s*"\d+/');

    # validate
    my $url_version_3 = "$dn/validate/$ruleset";
    #diag "Testing validate with $url_version_3";

    $mech->get_ok($url_version_3);
    $mech->field('rule',$test_ruleset);
    $mech->field('flavor', 'html');
    $mech->submit_form_ok();

    is($mech->content_type(), 'text/html');
    $mech->title_is('Validate KRL');
    $mech->content_contains('"ruleset_name":"10"');

    $mech->back();
    $mech->field('rule',$test_ruleset);
    $mech->field('flavor', 'json');
    $mech->submit_form_ok();

    is($mech->content_type(), 'text/plain');
    $mech->content_contains('"ruleset_name":"10"');

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
    diag "Testing $url_version_5";

    $mech->post_ok($url_version_5, ['krl'=> $test_ruleset]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_json_ruleset);


    # parse/rule
    my $url_version_6 = "$dn/parse/rule";
    diag "Testing $url_version_6";

    $mech->post_ok($url_version_6, ['krl'=> $test_rule]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_json_rule);


    # parse/global
    my $url_version_7 = "$dn/parse/global";
    diag "Testing $url_version_7";

    $mech->post_ok($url_version_7, ['krl'=> $test_global]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_json_global);


    # parse/ruleset
    my $url_version_8 = "$dn/unparse/ruleset";
    diag "Testing $url_version_8";

    $mech->post_ok($url_version_8, ['ast'=> $test_json_ruleset]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_ruleset);


    # unparse/rule
    my $url_version_9 = "$dn/unparse/rule";
    diag "Testing $url_version_9";

    $mech->post_ok($url_version_9, ['ast'=> $test_json_rule]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_rule_body);


    # unparse/global
    my $url_version_10 = "$dn/unparse/global";
    diag "Testing $url_version_10";

    $mech->post_ok($url_version_10, ['ast'=> $test_json_global]);

    is($mech->content_type(), 'text/plain');
    is_string_nows($mech->response()->content,$test_global);




}


1;




