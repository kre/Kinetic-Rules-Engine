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
$ast->update_context($rid);

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

my $context_id = $ast->get_context_id();
my $i = 0;
foreach my $rule (@{$ast->get_rules($context_id)}) {
  is($rule, "var rule = $i;", "Rule $i");
  $i++;
  $test_count++;
}

#diag $ast->generate_js();

my $lvjs = '';
if((Kynetx::Configure::get_config('USE_KVERIFY') || '0') == '1'){
  $lvjs = <<_JS_;
KOBJ.logVerify = KOBJ.logVerify || function(t,a,c){};KOBJ.logVerify('txn_id_1', 'cs_test', '127.0.0.1');
_JS_
}


my $js = <<_JS_;
KOBJ.registerClosure('cs_test', function(\$K) { (function(){var mjs = 0;var gjs = 0;var rule = 0;var rule = 1;var rule = 2;}()); $lvjs }, '$eid');
_JS_

is_string_nows($ast->generate_js(), $js, "Generating some JS");
$test_count++;

$ast->update_context($rid);
$ast->add_rule_js($rid, "var rule = 3;");
$ast->add_rule_js($rid, "var rule = 4;");
$ast->add_rule_js($rid, "var rule = 5;");

$js = <<_JS_;
KOBJ.registerClosure('cs_test', function(\$K) { (function(){var mjs = 0;var gjs = 0;var rule = 0;var rule = 1;var rule = 2;}()); $lvjs }, '$eid');
KOBJ.registerClosure('cs_test', function(\$K) { (function(){var mjs = 0;var gjs = 0;var rule = 3;var rule = 4;var rule = 5;}()); $lvjs }, '$eid');
_JS_

is_string_nows($ast->generate_js(), $js, "Generating some JS");
$test_count++;
#diag $ast->generate_js();


done_testing($test_count);



1;


