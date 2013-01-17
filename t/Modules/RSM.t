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
use Storable 'dclone';

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Modules::RSM qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Response qw/:all/;


use Kynetx::FakeReq qw/:all/;
use Kynetx::Util qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();


my $preds = Kynetx::Modules::RSM::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'may_delete';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);
my $session_token = "4E68C51C-551F-11E2-AC38-F1C2D835B985";

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid,{'sid' => $session_token});

my $session_ken = Kynetx::Persistence::KEN::get_ken($session,"null");
my $nid = Kynetx::Persistence::KEN::get_ken_value($session_ken,"user_id");
my $dd = Kynetx::Response->create_directive_doc($my_req_info->{'eid'});

my $test_count = 0;

my($config, $mods, $args, $krl, $krl_src, $js, $result, $v);
my ($description,$function_name);

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $rnd = $DICTIONARY[rand(@DICTIONARY)];
chomp($rnd);

my $prefix = $DICTIONARY[rand(@DICTIONARY)];
chomp($prefix);

$rid .= $rnd;

my $sval = "String data";
my $nval = 3.1415;
my $aval = ["a", "b"];
my $hval = {
	"a" => 1
};
my $jsval = '$K(function(x) = 5;)';

my $expected;

my $tests = [$sval,$nval,$aval,$hval,$jsval];

for my $value (@{$tests}) {
	my $key = $DICTIONARY[rand(@DICTIONARY)];
	chomp($key);
	$expected->{$key} = Kynetx::Expressions::infer_type($value);
	Kynetx::Persistence::Entity::put_edatum($rid,$session_ken,$key,$value);
	Kynetx::Persistence::Application::put($rid,$key,$value);
}

# Make entity datas
#$result = Kynetx::Persistence::Entity::put_edatum($rid,$session_ken,$skey,$key2);


$description = "Check entity data types";
$args = [];
$result = Kynetx::Modules::RSM::_entkeys($session_ken,$rid);
#$session_ken,$dev_key);
cmp_deeply($result,superhashof($expected),$description);
$test_count++;

$description = "Check application data types";
$args = [];
$result = Kynetx::Modules::RSM::_appkeys($rid);
#$session_ken,$dev_key);
cmp_deeply($result,superhashof($expected),$description);
$test_count++;

$description = "Create an empty ruleset registration";
$function_name = "new_ruleset";
$args = [];
$expected = 'a' . $nid . 'x';
$result = Kynetx::Modules::RSM::run_function($my_req_info,$rule_env,$session,$rule_name,$function_name,$args);
cmp_deeply($result,re(qr/^$expected/),$description);
$test_count++;

$rid = $result;

#  This *could* fail if the same random word is picked from the dictionary (wouldn't end 'x0')
$description = "Create an empty ruleset registration with a prefix";
$function_name = "new_ruleset";
$args = [$prefix];
$expected = $prefix . $nid . 'x0';
$result = Kynetx::Modules::RSM::run_function($my_req_info,$rule_env,$session,$rule_name,$function_name,$args);
cmp_deeply($result,re(qr/^$expected/),$description);
$test_count++;

$description = "Register a new ruleset";
my $local_file = 'data/action5.krl';
my $uri = "https://raw.github.com/kre/Kinetic-Rules-Engine/master/t/" . $local_file;
$krl_src = <<_KRL_;
  rsm:register("$uri") setting(myRid)
    with
      prefix = "$prefix" and
      flush_code = "4111" and 
      headers = {
			 "Accept" : "text/plain",
			 "Cache-Control" : "no-cache"
		  };
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');
$result = lookup_rule_env('myRid',$rule_env);
cmp_deeply($result->{'rid'},re(qr/$prefix$nid/),$description);
$test_count++;

my $new_rid = $result->{'rid'};

$description = "Validate the new ruleset";
$result = Kynetx::Modules::RSM::_validate($result->{'rid'});
cmp_deeply($result,1,$description);
$test_count++;

$description = "Use action to validate the new ruleset";
$krl_src = <<_KRL_;
  rsm:validate("$new_rid") setting (isValid);
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');
$result = lookup_rule_env('isValid',$rule_env);
cmp_deeply($result,1,$description);
$test_count++;


$description = "Register a bad ruleset";
$local_file = 'data/fails/fail0.krlb';
$uri = "file://$local_file";
$krl_src = <<_KRL_;
  rsm:register("$uri") setting (myRid)
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');
$result = lookup_rule_env('myRid',$rule_env);
cmp_deeply($result->{'rid'},re(qr/a$nid/),$description);
$test_count++;

$new_rid = $result->{'rid'};

$description = "Use action to invalidate the bad ruleset";
$krl_src = <<_KRL_;
  rsm:validate("$new_rid") setting (isValid);
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');
$result = lookup_rule_env('isValid',$rule_env);
cmp_deeply(ref $result,"ARRAY",$description);
$test_count++;

$logger->debug("Result: ", sub {Dumper($result)});


done_testing($test_count);



1;


