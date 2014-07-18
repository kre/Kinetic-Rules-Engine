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
use Cache::Memcached;
use Apache::Session::Memcached;

use APR::URI;
use APR::Pool ();
use LWP::UserAgent;

use JSON::XS;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Modules::Event qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::ExecEnv qw/:all/;

# required for schedev tests
use Kynetx::Predicates::Time;
use Kynetx::Modules::Random;
use Kynetx::Util qw(ll);
use Kynetx::Persistence::SchedEv;
use Kynetx::Persistence::KEN;


use Kynetx::FakeReq qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $preds = Kynetx::Modules::Event::get_predicates();
my @pnames = keys (%{ $preds } );


my $r = Kynetx::Test::configure();


my $rid = 'cs_test';
my $execenv = Kynetx::ExecEnv::build_exec_env();

# test choose_action and args

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $session = Kynetx::Test::gen_session($r, $rid);
my $session_id = Kynetx::Session::session_id($session);


my $token = 'a3a23a70-f2a9-012e-4216-00163e411455';
my $other_token = '44d92880-f2ca-012e-427d-00163e411455';


my $options = {'g_id' => $session_id, 
	       'ridver' => 'dev',
	       'id_token' => $token};
my $my_req_info = Kynetx::Test::gen_req_info($rid,$options);

my $dd = Kynetx::Response->create_directive_doc($my_req_info->{'eid'});

my %rule_env = ();

my $logger = get_logger();

my $test_count = int(@pnames);

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


##
## event:channel('id');
##

is(get_eventinfo($my_req_info, 'channel', ['id']),
   $token,
   'event:channel("id")');
$test_count++;


my $params = {
   'msg' => 'Hello World!',
 };


is_deeply(get_eventinfo($my_req_info, 'params', []), $params, "Params gives all");
$test_count++;

is(get_eventinfo($my_req_info, 'param', ['msg']), $params->{'msg'}, "Param");
$test_count++;

is_deeply(get_eventinfo($my_req_info, 'attrs', []), $params, "Attrs gives all");
$test_count++;

is(get_eventinfo($my_req_info, 'attr', ['msg']), $params->{'msg'}, "Attr");
$test_count++;

is(get_eventinfo($my_req_info, 'env', ['rid']),
   $rid,
   'event:env("rid")');
$test_count++;

is(get_eventinfo($my_req_info, 'type', []),
   Kynetx::Request::get_event_type($my_req_info),
   'event:type()');
$test_count++;

is(get_eventinfo($my_req_info, 'domain', []),
   Kynetx::Request::get_event_domain($my_req_info),
   'event:domain()');
$test_count++;



# set up AnyEvent
my $cv = AnyEvent->condvar();

Kynetx::ExecEnv::set_condvar($execenv,$cv);



$cv->begin(sub { shift->send("All threads complete") });

my $subscriptions = [{'token' => $token},
 		     {'token' => $other_token}];

my ($krl, $krl_src, $js);


foreach my $sm ( @{$subscriptions}) {


  my $sm_json = encode_json($sm);

  $krl_src = <<_KRL_;
event:send($sm_json, "notification", "status")
   with attrs = {"priority" : "2",
                 "appliaction" : "Flipper"
                }
_KRL_

  $krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#  diag Dumper $krl;

  $js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name',
	    $execenv
           );


# $result = lookup_rule_env('r',$rule_env);
# ok($result->{'content'} eq '', "Content undefined");
# ok($result->{'status_code'} eq '302', "Status code Found(?)");
# $test_count += 2;

#  diag $js;

}

$subscriptions = [{'eci' => $token},
		  {'eci' => $other_token}];

foreach my $sm ( @{$subscriptions}) {


  my $sm_json = encode_json($sm);

  $krl_src = <<_KRL_;
event:send($sm_json, "notification", "status")
   with attrs = {"priority" : "2",
                 "appliaction" : "Flipper"
                }
_KRL_

  $krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#  diag Dumper $krl;

  $js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name',
            $execenv
           );


# $result = lookup_rule_env('r',$rule_env);
# ok($result->{'content'} eq '', "Content undefined");
# ok($result->{'status_code'} eq '302', "Status code Found(?)");
# $test_count += 2;

#  diag $js;

}

$subscriptions = [{'flip' => $token},
		  {'flip' => $other_token}];

foreach my $sm ( @{$subscriptions}) {


  my $sm_json = encode_json($sm);

  $krl_src = <<_KRL_;
event:send($sm_json, "notification", "status")
   with attrs = {"priority" : "2",
                 "appliaction" : "Flipper"
                }
    and cid_key = "flip"
_KRL_

  $krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#  diag Dumper $krl;

  $js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name',
	    $execenv
           );


# $result = lookup_rule_env('r',$rule_env);
# ok($result->{'content'} eq '', "Content undefined");
# ok($result->{'status_code'} eq '302', "Status code Found(?)");
# $test_count += 2;

#  diag $js;

}


$cv->end;
$logger->debug($cv->recv);

# Tests for the scheduled events methods in Event
#Log::Log4perl->easy_init($DEBUG);
my $uname = Kynetx::Modules::Random::rword();
my $user_ken = Kynetx::Test::gen_user($my_req_info,$rule_env,$session,$uname);
my $sky_token = Kynetx::Persistence::KToken::get_default_token($user_ken);
my $sky_session = Kynetx::Session::process_session($r,undef,$sky_token);
my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');
my $dn = "http://$platform/sky/schedule/";

my $domain;
my $eventname;
my $timespec;
my $attr;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =  localtime(time);
my $now = Kynetx::Predicates::Time::now($my_req_info,'ad_hoc');
$domain = 'notification';
my $ename1 = '_test_' . Kynetx::Modules::Random::rword();
my $ename2 = '_test_' . Kynetx::Modules::Random::rword();
my $tsmin = $min + 2;
if ($tsmin > 59) {
  $tsmin = $tsmin - 59;
}

my $description = "Create a new recurring event";
$timespec = "$tsmin * * * *";
$attr->{'timezone'} = 'America/Denver';
my $sched_id = Kynetx::Persistence::SchedEv::repeating_event($user_ken,$rid,$domain,$ename1,$timespec,$attr);
#ll("Created: $sched_id");
my $schedEv = Kynetx::Persistence::SchedEv::get_sched_ev($sched_id);
#ll("$sched_id: ", sub {Dumper($schedEv)});

$description = "Check event list";
my $schedev1 = [$sched_id,"$domain/$ename1",'repeat',$rid,re(qr/\d{10}/)];
my $expected = [$schedev1];
cmp_deeply(get_eventinfo($my_req_info, 'get_list', [],$sky_session), $expected, $description);
$test_count++;

$description = "Single Event";
$timespec = Kynetx::Predicates::Time::add($my_req_info,"foo",[$now,{hours => 5}]);
$sched_id = Kynetx::Persistence::SchedEv::single_event($user_ken,$rid,$domain,$ename2,$timespec,$attr);
isnt($sched_id,undef,$description);
$test_count++;
my $single_event_id = $sched_id;

$description = "Check event list (repeat and single)";
my $schedev2 = [$sched_id,"$domain/$ename2",'once',$rid,re(qr/\d{10}/)];
$expected = bag($schedev2,$schedev1);
my $result = get_eventinfo($my_req_info, 'get_list', [],$sky_session);
#ll("$sched_id: ", sub {Dumper($result)});
cmp_deeply($result, $expected, $description);
$test_count++;

# Check that the single event can be called
my $url = $dn . $single_event_id;
my $ua = LWP::UserAgent->new;


$description = "A send event can be built from a schedEv";
$result = $ua->get($url);
is($result->code(),'200',$description);
$test_count++;

sleep 2; 

$description = "Get history of single event";
$result = get_eventinfo($my_req_info, 'get_history', [$single_event_id],$sky_session);
#ll("history $sched_id: ", sub {Dumper($result)});
is($result->{'code'},'200',$description);
$test_count++;


$description = "Delete the single event";
$expected = 1;
$result = get_eventinfo($my_req_info, 'delete', [$sched_id],$sky_session);
#ll("delete $sched_id: ", sub {Dumper($result)});
cmp_deeply($result, $expected, $description);
$test_count++;

$description = "Check the event list";
$expected = [$schedev1];
$result = get_eventinfo($my_req_info, 'get_list', [],$sky_session);
#ll("List: ", sub {Dumper($result)});
cmp_deeply($result, $expected, $description);
$test_count++;

Kynetx::Test::flush_test_user($user_ken,$uname);
done_testing($test_count);


1;


