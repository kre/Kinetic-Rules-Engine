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
use Kynetx::Modules::RuleEnv qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Rids qw/:all/;


use Kynetx::FakeReq qw/:all/;


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

my $memd = get_memd();


# test with first module sig

my $module_sig = "sldakdjdhakjdja";

my $mod_name = "flip";
my $mod_ver = "per";

my ($js, $provided, $mod_rule_env) = ("some js", ["a", "b"], {"a" => 1, "b" => 4});

Kynetx::Modules::RuleEnv::set_module_cache($module_sig, $my_req_info, $memd, $js, $provided, $mod_rule_env, $mod_name, $mod_ver);

my $module_cache = Kynetx::Modules::RuleEnv::get_module_cache($module_sig, $memd);

is_deeply($module_cache->{Kynetx::Modules::RuleEnv::get_re_key($module_sig)},
	  $mod_rule_env,
	  "Module rule env matches");

is($module_cache->{Kynetx::Modules::RuleEnv::get_js_key($module_sig)},
   $js,
   "Module JS matches");

is_deeply($module_cache->{Kynetx::Modules::RuleEnv::get_pr_key($module_sig)},
	  $provided,
	  "Module provided matches");
$test_count += 3;

# test with second module sig

my $module_sig_2 = "rwurwriuwroqieu";

($js, $provided, $mod_rule_env) = ("some other js", ["c", "d"], {"j" => 1, "k" => 4});

Kynetx::Modules::RuleEnv::set_module_cache($module_sig_2, $my_req_info, $memd, $js, $provided, $mod_rule_env, $mod_name, $mod_ver);


$module_cache = Kynetx::Modules::RuleEnv::get_module_cache($module_sig_2, $memd);

is_deeply($module_cache->{Kynetx::Modules::RuleEnv::get_re_key($module_sig_2)},
	  $mod_rule_env,
	  "Module rule env matches again");

is($module_cache->{Kynetx::Modules::RuleEnv::get_js_key($module_sig_2)},
   $js,
   "Module JS matches again");

is_deeply($module_cache->{Kynetx::Modules::RuleEnv::get_pr_key($module_sig_2)},
	  $provided,
	  "Module provided matches again");
$test_count += 3;

# test module sig list

my $msig_list = Kynetx::Modules::RuleEnv::get_msig_list($my_req_info, $memd);

ok($msig_list->{$module_sig}, "Module sig is there");

ok($msig_list->{$module_sig_2}, "Module sig 2 is there");

ok(! $msig_list->{"not a module sig"}, "Unknown module sig isn't there");

$test_count += 3;

Kynetx::Modules::RuleEnv::delete_module_caches($my_req_info, $memd);


# all undefined now!
is_deeply(Kynetx::Modules::RuleEnv::get_module_cache($module_sig, $memd),
	  {},
	  "Nothing defined for first module sig");
is_deeply(Kynetx::Modules::RuleEnv::get_module_cache($module_sig_2, $memd), 
	  {},
	  "Nothing defined for second module sig");
ok(!defined Kynetx::Modules::RuleEnv::get_msig_list($my_req_info, $memd), 
   "Nothing defined module sig list");
$test_count += 3;


# the module list should still be there (i.e. haven't flushed it)
my $mod_re_list = Kynetx::Modules::RuleEnv::get_mod_re_list($mod_name, $mod_ver, $memd);

ok($mod_re_list->{$module_sig}, "Module sig is still there for module");

ok($mod_re_list->{$module_sig_2}, "Module sig 2 is there for module");

ok(! $mod_re_list->{"not a module sig"}, "Unknown module sig isn't there for module");

$test_count += 3;


##
## save the old rid before we change it to the module in the req. 
my $old_rid = $my_req_info->{'rid'};
$my_req_info->{'rid'} = Kynetx::Rids::mk_rid_info($my_req_info,$mod_name, {'version' => $mod_ver});

Kynetx::Modules::RuleEnv::delete_module_caches($my_req_info, $memd);


# all undefined now!
is_deeply(Kynetx::Modules::RuleEnv::get_module_cache($module_sig, $memd),
	  {},
	  "Nothing defined for first module sig");
is_deeply(Kynetx::Modules::RuleEnv::get_module_cache($module_sig_2, $memd), 
	  {},
	  "Nothing defined for second module sig");
ok(!defined Kynetx::Modules::RuleEnv::get_mod_re_list($mod_name, $mod_ver, $memd), 
   "Nothing defined module sig list");
$test_count += 3;


##
## put the rid back
##
$my_req_info->{'rid'} = $old_rid;



done_testing($test_count);



1;


