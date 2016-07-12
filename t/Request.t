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
use APR::URI;
use APR::Pool ();
use Cache::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Request qw/:all/;
use Kynetx::JavaScript qw/:all/;

use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::FakeReq qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $test_count = 0;
my $logger=get_logger();

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid, {'domain' => 'web'});


my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

$my_req_info->{'domain'} = 'web';
set_capabilities($my_req_info);

ok($my_req_info->{'understands_javascript'}, "Web understands JS");
$test_count++;

$my_req_info->{'domain'} = 'email';
set_capabilities($my_req_info);

ok($my_req_info->{'understands_javascript'}, "Email does not understands JS");
$test_count++;

### Test JSON POST
my $mod_rid = 'a144x157.prod';
my @default_rules = ['cs_test','10','a144x171.dev',$mod_rid];
my $test_env = Kynetx::Test::enchilada('ridlist','ridlist_rule',\@default_rules);

subtest 'Environment created' => sub {Kynetx::Test::validate_env($test_env)};
$test_count++;

######################### Test Environment definitions
my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'kibdev');

my $mode = "http://";
$mode = "https://" unless ($platform eq '127.0.0.1');

my $req_info = $test_env->{'req_info'};
my $sky_info = $test_env->{'sky_request_info'};
my $rule_env = $test_env->{'root_env'};
my $session  = $test_env->{'session'};
my $rulename = $test_env->{'rulename'};

my $anon_ken = $test_env->{'anonymous_user'};

my $user_ken = $test_env->{'user_ken'};
my $user_eci = $test_env->{'user_eci'};
my $user_username = $test_env->{'username'};
my $user_password = $test_env->{'password'};

my $t_rid = $test_env->{'rid'};
my $t_eid = $test_env->{'eid'};
#########################

my $ua = LWP::UserAgent->new;
my $key = Kynetx::Modules::Random::rword();
my $value = Kynetx::Modules::Random::rword();

my $hash = {
  $key => $value
};
my $json = JSON::XS::->new->convert_blessed(1)->pretty(1)->encode($hash);
my $sky_uri = "$mode$platform/sky/event/$user_eci";
my $cloud_uri = "$mode$platform/sky/cloud/";
my $domain = "notification";
my $eventname = "agrajag";
my $re = qr/^foo\{.*\"$key\":\"$value\".*\}off$/;

$logger->level($DEBUG);

my $url = "$sky_uri?_rids=$mod_rid&_domain=$domain&_name=$eventname";
my $req = HTTP::Request->new(POST => $url);
$req->header('Content-Type'=>'application/json');
$req->content($json);

my $expected;
my $result = $ua->request($req);

my $description = "POST using GET style url params";
$logger->debug("Content: ", $result->content());
cmp_deeply($result->content(),re($re),$description);
$test_count++;


$description = "POST using pure JSON to pass parameters";
$url = $sky_uri;
$hash = {
  $key => $value,
  "_rids" => $mod_rid,
  "_domain" =>$domain,
  "_name" => $eventname  
};
$json = JSON::XS::->new->convert_blessed(1)->pretty(1)->encode($hash);
$req = HTTP::Request->new(POST => $url);
$req->header('Content-Type'=>'application/json');
$req->content($json);

$result = $ua->request($req);

$description = "POST using pure JSON to pass parameters";
$logger->debug("Content: ", $result->content());
cmp_deeply($result->content(),re($re),$description);
$test_count++;

######################### Attributes

$description = "Add an attribute";
Kynetx::Request::add_event_attr($my_req_info, "flip", "flop");
is(Kynetx::Request::get_attr($my_req_info, "flip"), "flop", $description);
$test_count++;

$description = "Get attribute names";
$expected = ["msg", "flip"];
$result = Kynetx::Request::get_attr_names($my_req_info);
cmp_deeply($result, $expected, $description);
$test_count++;

$description = "Add a reserved word attribute";
Kynetx::Request::add_event_attr($my_req_info, "type", "tope");
is(Kynetx::Request::get_attr($my_req_info, "type"), undef, $description);
$test_count++;

$description = "Add an attribute";
Kynetx::Request::add_event_attr($my_req_info, "name", "flop");
is(Kynetx::Request::get_attr($my_req_info, "name"), "flop", $description);
$test_count++;



######################### Clean up
Kynetx::Test::flush_test_user($user_ken,$user_username);

my $anon_uname = "_" . $anon_ken;
Kynetx::Test::flush_test_user($anon_ken,$anon_uname);

done_testing($test_count);

1;


