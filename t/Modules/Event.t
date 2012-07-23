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
use Cache::Memcached;
use Apache::Session::Memcached;

use APR::URI;
use APR::Pool ();

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
   'caller' => 'http://www.windley.com/'
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

$subscriptions = [{'cid' => $token},
		  {'cid' => $other_token}];

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

# while (my ($k, $v) = each (%{$execenv->get_results()})) {
#   diag "$k: ". Dumper($v)  . "\n";
# }


done_testing($test_count);


1;


