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
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Modules::ECI qw/:all/;
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


my $preds = Kynetx::Modules::ECI::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $session_ken = Kynetx::Persistence::KEN::get_ken($session,"null");

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

# most basic requests
my $test_site = "http://www.httpbin.org";
my $stest_site = "https://www.httpbin.org";

my $dd = Kynetx::Response->create_directive_doc($my_req_info->{'eid'});

my $uuid_re = "^[A-F|0-9]{8}\-[A-F|0-9]{4}\-[A-F|0-9]{4}\-[A-F|0-9]{4}\-[A-F|0-9]{12}\$";
$krl_src = <<_KRL_;
// get a new token
eci:new() setting(r) 	  
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;
my @kenArray = ();

$js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

$result = lookup_rule_env('r',$rule_env);
my $description = "Create a new CDI through an Action using modifiers";
cmp_deeply($result,re($uuid_re),$description);
$test_count++;
push(@kenArray,$result);

my $et = "PCloud";

$krl_src = <<_KRL_;
// get a new token
eci:new() setting (r)
	with eci_type = "$et";	  
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

$result = lookup_rule_env('r',$rule_env);
$description = "Check for correct endpoint_type";
cmp_deeply($result,re($uuid_re),$description);
$test_count++;

my $token = Kynetx::Persistence::KEN::token_query({'ktoken' => $result});

$description = "Create a new CDI through an Action using defaults";
cmp_deeply($token->{'endpoint_type'},$et,$description);
$test_count++;

push(@kenArray,$result);


$krl_src = <<_KRL_;
// get a new token
eci:new_cloud() setting(r) 	  
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

$result = lookup_rule_env('r',$rule_env);
$description = "Create a new Account/KEN through an Action";
cmp_deeply($result,re($uuid_re),$description);
$test_count++;

$description = "Check that the token returned has a different KEN";
$token = Kynetx::Persistence::KEN::token_query({'ktoken' => $result});
my $alt_token = $result;
my $new_ken = $token->{"ken"};
isnt($session_ken,$new_ken,$description);
$test_count++;

my $string = "\"" . join("\",\"",@kenArray) . "\"";

# check Predicates
$description = "Check two tokens for ownership";
$krl_src = <<_KRL_;
r = eci:compare([$string]);
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);
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


is($result,1,$description);
$test_count++;

my @not_same = @kenArray;
push(@not_same,$alt_token);
$string = "\"" . join("\",\"",@not_same) . "\"";

ll($string);


$description = "Check for mis-match token";
$krl_src = <<_KRL_;
r = eci:compare([$string]);
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);
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


is($result,0,$description);
$test_count++;

#check module
$description = "Create new token from expression";
my $source = 'eci';
my $function = 'new';
$args = [];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
cmp_deeply($result,re($uuid_re),$description);
$test_count++;

push(@kenArray,$result);

$string = "\"" . join("\",\"",@kenArray) . "\"";
$description = "Check three tokens for ownership";
$krl_src = <<_KRL_;
r = eci:compare([$string]);
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);
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


is($result,1,$description);
$test_count++;

$description = "Check three tokens for ownership";
$krl_src = <<_KRL_;
r = eci:new_cloud();
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);
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

cmp_deeply($result,re($uuid_re),$description);
$test_count++;

push(@kenArray,$result);

$string = "\"" . join("\",\"",@kenArray) . "\"";
$description = "Check four tokens for mis-match";
$krl_src = <<_KRL_;
r = eci:compare([$string]);
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);
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


is($result,0,$description);
$test_count++;



done_testing($test_count);



1;


