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

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use Cache::Memcached;
use LWP::Simple;
use LWP::UserAgent;
use JSON::XS;
use AnyEvent ();
use AnyEvent::HTTP ();
use Storable qw(dclone);


use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rules qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Modules qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence qw/:all/;
use Kynetx::Response qw/:all/;
use Kynetx::Rids qw/:all/;
use Kynetx::ExecEnv qw/:all/;


use Kynetx::FakeReq;

use Log::Log4perl::Level;
#use Log::Log4perl::Appender::FileLogger;
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($WARN);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();

# configure logging for production, development, etc.
#config_logging($r);
#Kynetx::Util::turn_off_logging();

my $logger = get_logger();

my $rid = 'cs_test';

# test choose_action and args



my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $my_req_info = Kynetx::Test::gen_req_info($rid);

#diag Dumper $rule_env;

my $session = Kynetx::Test::gen_session($r, $rid);

my $ast = Kynetx::JavaScript::AST->new('13893139103801');


my $memd = get_memd();

my($krl, $module_rs, $js, $mod_rule_env, $empty_rule_env, $env_stash, 
   $test_count,
   $result, $expected
  );

$test_count = 0;

$env_stash = {};


diag "############ use a16x78 alias foo with c configured #################";
diag "############ use a16x78 alias bar with c configured #################";
# test module configuration
$krl =  << "_KRL_";
ruleset foobar {
  meta {
    key floppy "world"
    use module a16x78 alias foo with c = "FOO"
    use module a16x78 version "dev" alias bar with c = "BAR"
  }
  global {
    a = foo:g();
    b = bar:g();
  }
}
_KRL_


$module_rs = Kynetx::Parser::parse_ruleset($krl);
# # diag Dumper $module_rs;

# hard coded value...if module or use changes, so will sig
my $sig = "d9a8bdbe8cd641967bab4477598eb0fd";

$mod_rule_env = Kynetx::Rules::get_rule_env($my_req_info, $module_rs, $session, $ast, $env_stash);

#diag Dumper $mod_rule_env;

$expected = {
   'floppy' => 1,
   'a' => 1,
   'my_ver' => 1,
   'flippy' => 1,
   'calling_rid' => 1,
   'calling_ver' => 1,
   'search_twitter' => 1,
   'my_rid' => 1,
   'g' => 1,
   'f' => 1
 };


$result = Kynetx::Request::get_module_provides($sig, $my_req_info);
is_deeply($result, $expected, "Provides for $sig");
$test_count++;

$result = Kynetx::Environments::lookup_rule_env("a",Kynetx::Request::get_module_env("d9a8bdbe8cd641967bab4477598eb0fd", $my_req_info));

$expected = 5;
is($result, $expected, "Looking up a in $sig");
$test_count++;


diag "############# use, use, use ";
$env_stash = {};


# test module configuration
# use a1856x10 twice. It uses a1856x9 once, which uses a16x78 once;
# so there are four unique modules. Make sure that's all we get. 
# Old method would have given us six. 
$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a1856x10 alias flop with x = 10
    use module a1856x10 alias flip with x = 11
    
  }
  global {
    x = flop:a2;
  }
}
_KRL_

$module_rs = Kynetx::Parser::parse_ruleset($krl);
#diag Dumper $module_rs;

$mod_rule_env = Kynetx::Rules::get_rule_env($my_req_info, $module_rs, $session, $ast, $env_stash);

#diag Dumper $mod_rule_env;
diag Dumper keys %{$my_req_info->{"module:defs"} };

is(4, scalar (keys %{ $my_req_info->{"module:defs"} }), "There are four modules in the req_info");
$test_count++;


done_testing($test_count);
