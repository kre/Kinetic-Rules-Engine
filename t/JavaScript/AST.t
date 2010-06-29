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
use Kynetx::JavaScript::AST qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;

my $eid = time;
my $txn_id = 'txn_id_1';

my $ast = Kynetx::JavaScript::AST->new($eid);

is($ast->get_eid(), $eid, "EID is right");
$test_count++;

$ast->add_rid_js($rid, "var mjs = 0;", "var gjs = 0;", {'ruleset_name' => $rid}, $txn_id);

is($ast->get_global($rid), "var gjs = 0;", "Globals work");
is($ast->get_meta($rid), "var mjs = 0;", "Metas work");
is_deeply($ast->get_ruleset($rid), {'ruleset_name' => $rid}, "Ruleset work");
is($ast->get_txn_id($rid), $txn_id, "txn_id works");
$test_count += 4;

$ast->add_rule_js($rid, "var rule = 0;");
$ast->add_rule_js($rid, "var rule = 1;");
$ast->add_rule_js($rid, "var rule = 2;");

my $i = 0;
foreach my $rule (@{$ast->get_rules($rid)}) {
  is($rule, "var rule = $i;", "Rule $i");
  $i++;
  $test_count++;
}

#diag $ast->generate_js();

my $js = <<_JS_;
KOBJ.registerClosure('cs_test', function(\$K) { (function(){var mjs = 0;var gjs = 0;var rule = 0;var rule = 1;var rule = 2;}());
KOBJ.logVerify = KOBJ.logVerify || function(t,a,c){};KOBJ.logVerify('txn_id_1', 'cs_test', '127.0.0.1'); }, '$eid');
_JS_

is_string_nows($ast->generate_js(), $js, "Generating some JS");
$test_count++;

done_testing($test_count);



1;


