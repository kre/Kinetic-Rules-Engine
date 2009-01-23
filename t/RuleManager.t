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

use Kynetx::Test qw/:all/;
use Kynetx::RuleManager qw/:all/;

my $numtests = 22;
plan tests => $numtests;

my $dn = "http://127.0.0.1/manage";

my $ruleset = "cs_test";

my $mech = Test::WWW::Mechanize->new();

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
{"global":[],"dispatch":[],"ruleset_name":"10","rules":[{"cond":{"predicate":"daytime","args":[],"type":"simple"},"blocktype":"choose","actions":[{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_1.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"gift certificate","type":"str"},{"val":"yellow","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"30","type":"num"},"name":"delay"}]},"label":"first_rule_name"},{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_2.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"discount","type":"str"},{"val":"blue","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"true","type":"bool"},"name":"draggable"}]},"label":"second_rule_name"}],"post":null,"pre":[],"name":"test_choose","emit":null,"state":"inactive","callbacks":{"success":[{"attribute":"id","value":"rssfeed","type":"click"},{"attribute":"class","value":"newsletter","type":"click"}],"failure":[{"attribute":"id","value":"close_rss","type":"click"}]},"pagetype":{"pattern":"/identity-policy/","vars":[]}}]}
JSON

my $test_json_rule = <<JSON;
{"cond":{"predicate":"daytime","args":[],"type":"simple"},"blocktype":"choose","actions":[{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_1.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"gift certificate","type":"str"},{"val":"yellow","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"30","type":"num"},"name":"delay"}]},"label":"first_rule_name"},{"action":{"name":"replace","args":[{"val":"kobj_test","type":"str"},{"val":"/kynetx/newsletter_invite_2.inc","type":"str"}],"modifiers":[{"value":{"val":[{"val":"discount","type":"str"},{"val":"blue","type":"str"}],"type":"array"},"name":"tags"},{"value":{"val":"true","type":"bool"},"name":"draggable"}]},"label":"second_rule_name"}],"post":null,"pre":[],"name":"test_choose","emit":null,"state":"inactive","callbacks":{"success":[{"attribute":"id","value":"rssfeed","type":"click"},{"attribute":"class","value":"newsletter","type":"click"}],"failure":[{"attribute":"id","value":"close_rss","type":"click"}]},"pagetype":{"pattern":"/identity-policy/","vars":[]}}
JSON

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$ruleset";
    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $numtests if (! $response->is_success);

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
    #diag "Testing validate with $url_version_4"

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




}


1;




