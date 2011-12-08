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
#use diagnostics;

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
no warnings 'uninitialized';
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Events::State qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Events::Primitives qw/:all/;
use Kynetx::Events qw(compile_event_expr);


use Kynetx::FakeReq qw/:all/;

my $logger = get_logger();

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $test_count = 0;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';
my $session = Kynetx::Test::gen_session($r, $rid);
my $initial;
my $next;
my $temp;
my $flush = 0;

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $ev1 = Kynetx::Events::Primitives->new();
$ev1->pageview($my_req_info->{'caller'});

my $ev2 = Kynetx::Events::Primitives->new();
$ev2->pageview("http://www.kynetx.com/this/is/a/bad/url.html");

my $ev3 = Kynetx::Events::Primitives->new();
$ev3->pageview("http://www.google.com/");

my $ev4 = Kynetx::Events::Primitives->new();
$ev4->pageview("http://www.yahoo.com/");

my $evc0 = Kynetx::Events::Primitives->new();
$evc0->click(".panelNavAdd.*");

my $evc1 = Kynetx::Events::Primitives->new();
$evc1->generic("web","news_search");

my $evc2 = Kynetx::Events::Primitives->new();
$evc2->generic("explicit","news_search");

# test the pageview prim SMs
my $skey = "sm1";
my $sm1 = Kynetx::Memcached::check_cache($skey);

if (defined $sm1  && ! $flush) {
	$sm1 = Kynetx::Events::State->unserialize($sm1);
} else {
	$sm1 = mk_pageview_prim(qr/www.windley.com/);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm1);
	Kynetx::Memcached::mset_cache($skey,$json);
}


$skey = "sm2";
my $sm2 = Kynetx::Memcached::check_cache($skey);
if (defined $sm2 && ! $flush) {
	$sm2 = Kynetx::Events::State->unserialize($sm2);
} else {
	$sm2 = mk_pageview_prim(qr#/(..)/(a)#, ['vv','bb']);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm2);
	Kynetx::Memcached::mset_cache($skey,$json);
}


$skey = "sm3";
my $sm3 = Kynetx::Memcached::check_cache($skey);
if (defined $sm3  && ! $flush) {
	$sm3 = Kynetx::Events::State->unserialize($sm3);
} else {
	$sm3 = mk_pageview_prim(qr/www.google.com/);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm3);
	Kynetx::Memcached::mset_cache($skey,$json);
}


###############
#Log::Log4perl->easy_init($DEBUG);
###############

$skey = "timed_and";
my $timed = Kynetx::Memcached::check_cache($skey);

if (defined $timed  && ! $flush) {
	$timed = Kynetx::Events::State->unserialize($timed);
} else {
	$timed = mk_and($sm1,$sm2);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($timed);
	Kynetx::Memcached::mset_cache($skey,$json);
}
$timed->timeframe(1);

#$logger->debug("Timed: ", sub {Dumper($timed)});
$initial = $timed->get_initial();
$next = $timed->next_state($initial,$ev1,$rid,$session,$rule_name);
sleep(2);
$next = $timed->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($timed->is_final($next),0, "Failed timeframe");
$test_count++;

cmp_deeply($next,$initial,"State returns to initial");
$test_count++;



$next = $timed->next_state($initial,$ev2,$rid,$session,$rule_name);
cmp_deeply($timed->is_final($next),0, "New timeframe");
$test_count++;


isnt($next,$initial,"Started from beginning");
$test_count++;

$next = $timed->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($timed->is_final($next),1, "No delay so should be final");
$test_count++;

Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

#######
#goto ENDY;
#######

#######
# Refresh state counter
#######
Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);



my $t_count = mk_count($sm1,3);
$t_count->timeframe(3);
$initial = $t_count->get_initial();
$logger->debug("Count sm: ", sub {Dumper($t_count)});


$logger->debug("Count initial: ", sub {Dumper($initial)});
$next = $t_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($t_count->is_final($next),0, "First matching event, no transition");
$test_count++;

sleep(2);

$next = $t_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($t_count->is_final($next),0, "another matching event, no transition");
$test_count++;

sleep(2);

$next = $t_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($t_count->is_final($next),0, "Third matching event, first timed out, no transition");
$test_count++;

$next = $t_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($t_count->is_final($next),1, "Third matching event in timeframe: transition");
$test_count++;

#$next = $t_count->next_state($initial,$ev1,$rid,$session,$rule_name);
#cmp_deeply($t_count->is_final($next),1, "third matching event, is final");
#$test_count++;


$flush = 0;
$skey = "count3aandb";
my $c_count = Kynetx::Memcached::check_cache($skey);
if (defined $c_count && ! $flush) {
	$c_count = Kynetx::Events::State->unserialize($c_count);
} else {
	$c_count = mk_and($t_count,$sm2);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($c_count);
	Kynetx::Memcached::mset_cache($skey,$json);
}

$initial = $c_count->get_initial();
$logger->debug("Timed count/compound and: ", sub {Dumper($c_count)});

#######
# Refresh state counter
#######
Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);


$logger->debug("Count initial: ", sub {Dumper($initial)});
$next = $c_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($c_count->is_final($next),0, "First matching event, no transition");
$test_count++;
$logger->debug("1st A: $next");

sleep(2);

$next = $c_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($c_count->is_final($next),0, "another matching event, no transition");
$test_count++;
$logger->debug("2nd A: $next");


$next = $c_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($c_count->is_final($next),0, "EV2: no transition yet ");
$test_count++;
$logger->debug("1st B: $next");



sleep(2);

$next = $c_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($c_count->is_final($next),0, "Third matching event, first timed out, no transition");
$test_count++;
$logger->debug("3rd A (timeout): $next");

$next = $c_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($c_count->is_final($next),1, "Third matching event in timeframe and B");
$test_count++;


#-----------------------------
# Aggregates
#-----------------------------

my $vals = [3, 7, 9, 12, 6];
my @evagg = ();

foreach my $val (@{$vals}) {
	my $ev = Kynetx::Events::Primitives->new();
	$ev->generic("car","moving");
	my $req_info = Kynetx::Test::gen_req_info($rid,{'distance' => $val});
	$ev->set_req_info($req_info);
	push (@evagg,$ev);
}

my $filter = [
                {
                  'pattern' => '(\\d+)',
                  'type' => 'distance'
                }
              ];
my $sm0 =  mk_gen_prim('car','moving',undef,$filter);

my $id = 'mx';

my $agg = {
	'agg_op' => 'sum',
	'vars' => [
		{
		'type' => 'var',
		'val' => $id
		}
	]
};

$logger->debug("simple event: ", sub{Dumper($sm0)} );

$initial = $sm0->get_initial();

$next = $sm0->next_state($initial,$evagg[0],$rid,$session,$rule_name);
cmp_deeply($sm0->is_final($next),1, "Matching eventfinal");
$test_count++;

my $acount = mk_count($sm0,3,$agg);
$logger->debug("agg event: ", sub{Dumper($acount)} );

$initial = $acount->get_initial();

$next = $acount->next_state($initial,$evagg[0],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[1],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[2],'stu', $session, $rule_name);

cmp_deeply($acount->is_final($next),1, "Matching eventfinal");
$test_count++;
$logger->debug("agg val: ", sub{Dumper($evagg[2])} );
cmp_deeply($evagg[2]->{'vals'}, {$acount->{'id'}=>[19]}, "Sum");
$test_count++;

#######
# Refresh state counter
#######
Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

my $agg_and_time = $acount->clone();
$agg_and_time->timeframe(3);

$initial = $agg_and_time->get_initial();
$next = $agg_and_time->next_state($initial,$evagg[0],'stu', $session, $rule_name);
sleep 2;
$next = $agg_and_time->next_state($initial,$evagg[1],'stu', $session, $rule_name);
sleep 2;
$next = $agg_and_time->next_state($initial,$evagg[2],'stu', $session, $rule_name);
cmp_deeply($agg_and_time->is_final($next),0, "Expired event");
$test_count++;
$next = $agg_and_time->next_state($initial,$evagg[3],'stu', $session, $rule_name);
cmp_deeply($agg_and_time->is_final($next),1, "Matching eventfinal");
$test_count++;

$logger->debug("agg val2: ", sub{Dumper($evagg[2])} );
$logger->debug("agg val3: ", sub{Dumper($evagg[3])} );
cmp_deeply($evagg[3]->{'vals'}, {$agg_and_time->{'id'}=>[28]}, "Timed Sum");
$test_count++;


@evagg = ();

foreach my $val (@{$vals}) {
	my $ev = Kynetx::Events::Primitives->new();
	$ev->generic("car","moving");
	my $req_info = Kynetx::Test::gen_req_info($rid,{'distance' => $val});
	$ev->set_req_info($req_info);
	push (@evagg,$ev);
}

$agg = {
	'agg_op' => 'min',
	'vars' => [
		{
		'type' => 'var',
		'val' => $id
		}
	]
};

$acount = mk_count($sm0,3,$agg);
$logger->debug("agg event: ", sub{Dumper($acount)} );

$initial = $acount->get_initial();

$next = $acount->next_state($initial,$evagg[0],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[1],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[2],'stu', $session, $rule_name);

cmp_deeply($acount->is_final($next),1, "Matching eventfinal");
$test_count++;
$logger->debug("agg val: ", sub{Dumper($evagg[2])} );
cmp_deeply($evagg[2]->{'vals'}, {$acount->{'id'}=>[3]}, "min");
$test_count++;

@evagg = ();

foreach my $val (@{$vals}) {
	my $ev = Kynetx::Events::Primitives->new();
	$ev->generic("car","moving");
	my $req_info = Kynetx::Test::gen_req_info($rid,{'distance' => $val});
	$ev->set_req_info($req_info);
	push (@evagg,$ev);
}

$agg = {
	'agg_op' => 'max',
	'vars' => [
		{
		'type' => 'var',
		'val' => $id
		}
	]
};

$acount = mk_count($sm0,3,$agg);
$logger->debug("agg event: ", sub{Dumper($acount)} );

$initial = $acount->get_initial();

$next = $acount->next_state($initial,$evagg[0],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[1],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[2],'stu', $session, $rule_name);

cmp_deeply($acount->is_final($next),1, "Matching eventfinal");
$test_count++;
$logger->debug("agg val: ", sub{Dumper($evagg[2])} );
cmp_deeply($evagg[2]->{'vals'}, {$acount->{'id'}=>[9]}, "max");
$test_count++;


@evagg = ();

foreach my $val (@{$vals}) {
	my $ev = Kynetx::Events::Primitives->new();
	$ev->generic("car","moving");
	my $req_info = Kynetx::Test::gen_req_info($rid,{'distance' => $val});
	$ev->set_req_info($req_info);
	push (@evagg,$ev);
}

$agg = {
	'agg_op' => 'avg',
	'vars' => [
		{
		'type' => 'var',
		'val' => $id
		}
	]
};

$acount = mk_count($sm0,3,$agg);
$logger->debug("agg event: ", sub{Dumper($acount)} );

$initial = $acount->get_initial();

$next = $acount->next_state($initial,$evagg[0],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[1],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[2],'stu', $session, $rule_name);

cmp_deeply($acount->is_final($next),1, "Matching eventfinal");
$test_count++;
$logger->debug("agg val: ", sub{Dumper($evagg[2])} );
cmp_deeply($evagg[2]->{'vals'}, {$acount->{'id'}=>[19/3]}, "avg");
$test_count++;

@evagg = ();

foreach my $val (@{$vals}) {
	my $ev = Kynetx::Events::Primitives->new();
	$ev->generic("car","moving");
	my $req_info = Kynetx::Test::gen_req_info($rid,{'distance' => $val});
	$ev->set_req_info($req_info);
	push (@evagg,$ev);
}

$agg = {
	'agg_op' => 'push',
	'vars' => [
		{
		'type' => 'var',
		'val' => $id
		}
	]
};

$acount = mk_count($sm0,3,$agg);
$logger->debug("agg event: ", sub{Dumper($acount)} );

$initial = $acount->get_initial();

$next = $acount->next_state($initial,$evagg[0],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[1],'stu', $session, $rule_name);

$next = $acount->next_state($initial,$evagg[2],'stu', $session, $rule_name);

cmp_deeply($acount->is_final($next),1, "Matching eventfinal");
$test_count++;
$logger->debug("agg val: ", sub{Dumper($evagg[2])} );
cmp_deeply($evagg[2]->{'vals'}, {$acount->{'id'}=>[[3,7,9]]}, "push");
$test_count++;

my $edast = {
          'timeframe' => undef,
          'args' => [
            {
              'domain' => 'explicit',
              'type' => 'prim_event',
              'vars' => undef,
              'op' => 'news_search'
            },
            {
              'domain' => 'web',
              'filters' => [],
              'type' => 'prim_event',
              'vars' => undef,
              'op' => 'news_search'
            }
          ],
          'type' => 'complex_event',
          'op' => 'or'
        };
        

my $smEd0 = mk_dom_prim(".panelNavAdd.*", undef,undef,"click" );
$logger->debug("Ed event: ", sub {Dumper($smEd0)});

$initial = $smEd0->get_initial();

$next = $smEd0->next_state($initial,$evc0,$rid,$session,$rule_name);

$logger->debug("Ed final: ",$smEd0->is_final($next));
cmp_deeply($smEd0->is_final($next),1, "Matching event, not final");
$test_count++;

my $edsm1 = Kynetx::Events::compile_event_expr($edast,{});


# test for events in different domains but with same label
$initial = $edsm1->get_initial();
$next = $edsm1->next_state($initial,$evc1,$rid,$session,$rule_name);
cmp_deeply($edsm1->is_final($next),1, "Matching eventfinal");
$test_count++;

$next = $edsm1->next_state($initial,$evc2,$rid,$session,$rule_name);
cmp_deeply($edsm1->is_final($next),1, "Matching eventfinal");
$test_count++;

$next = $edsm1->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($edsm1->is_final($next),0, "No match");
$test_count++;

cmp_deeply($initial,$next, "Stays in initial state");
$test_count++;



my @sm_arry;
push(@sm_arry, $sm1);
push(@sm_arry, $sm2);
push(@sm_arry, $sm3);

my $thenmany = mk_then_n(\@sm_arry);
$logger->debug("then Many: ", sub {Dumper($thenmany)});
$initial = $thenmany->get_initial();

$next = $thenmany->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),0, "Matching event, not final");
$test_count++;

isnt($next,$initial,"Event match, transition");
$test_count++;

$next = $thenmany->next_state($initial,$ev3,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),0, "non event, not final");
$test_count++;

is($next,$initial,"Event match, reset to initial");
$test_count++;

$next = $thenmany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),0, "Matching event, not final");
$test_count++;

isnt($next,$initial,"Event match, transition");
$test_count++;

$temp = $next;
$next = $thenmany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),0, "Matching event, not final");
$test_count++;

is($next,$initial,"No match, reset to initial");
$test_count++;

$temp = $next;
$next = $thenmany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),0, "Matching event, not final");
$test_count++;

isnt($next,$initial,"first match, transition");
$test_count++;

$temp = $next;
$next = $thenmany->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),0, "Matching event, not final");
$test_count++;
$logger->debug("Cap event: ", sub {Dumper($ev2)});

isnt($next,$temp,"second match, transition");
$test_count++;

$next = $thenmany->next_state($next,$ev3,$rid,$session,$rule_name);
cmp_deeply($thenmany->is_final($next),1, "3rd Matching event, final");
$test_count++;


my $aftermany = mk_after_n(\@sm_arry);
$logger->debug("after Many: ", sub {Dumper($aftermany)});
$initial = $aftermany->get_initial();

$next = $aftermany->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($aftermany->is_final($next),0, "non event, not final");
$test_count++;

is($next,$initial,"no match state, no transition");
$test_count++;

$next = $aftermany->next_state($initial,$ev3,$rid,$session,$rule_name);
cmp_deeply($aftermany->is_final($next),0, "first event, not final");
$test_count++;

isnt($next,$initial,"Event match, transition");
$test_count++;

$temp = $next;

$next = $aftermany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($aftermany->is_final($next),0, "non event, not final");
$test_count++;

is($next,$temp,"no match state, no transition");
$test_count++;

$temp = $next;


$next = $aftermany->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($aftermany->is_final($next),0, "Match, not final");
$test_count++;

isnt($next,$temp,"Event match, transition");
$test_count++;

$next = $aftermany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($aftermany->is_final($next),1, "Match, final");
$test_count++;


my $beforemany = mk_before_n(\@sm_arry);
$logger->debug("before Many: ", sub {Dumper($beforemany)});
$initial = $beforemany->get_initial();

$next = $beforemany->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($beforemany->is_final($next),0, "first event, not final");
$test_count++;

isnt($next,$initial,"Matching state, transition");
$test_count++;

$temp = $next;

$next = $beforemany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($beforemany->is_final($next),0, "no match, not final");
$test_count++;

is($next,$temp,"no match state, transition");
$test_count++;

$temp = $next;

$next = $beforemany->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($beforemany->is_final($next),0, "match, not final");
$test_count++;

isnt($next,$temp,"match state, transition");
$test_count++;

$next = $beforemany->next_state($next,$ev3,$rid,$session,$rule_name);
cmp_deeply($beforemany->is_final($next),1, "match, is final");
$test_count++;

my $ormany = mk_or_n(\@sm_arry);

$logger->debug("or Many: ", sub {Dumper($ormany)});

$initial = $ormany->get_initial();

$next = $ormany->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($ormany->is_final($next),1, "matching event, final");
$test_count++;

$next = $ormany->next_state($initial,$ev2,$rid,$session,$rule_name);
cmp_deeply($ormany->is_final($next),1, "matching event, final");
$test_count++;

$next = $ormany->next_state($initial,$ev3,$rid,$session,$rule_name);
cmp_deeply($ormany->is_final($next),1, "matching event, final");
$test_count++;



$skey = "andmany";
my $andmany = Kynetx::Memcached::check_cache($skey);

if (defined $andmany  && ! $flush) {
	$andmany = Kynetx::Events::State->unserialize($andmany);
} else {
	$andmany = mk_and_n(\@sm_arry);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($andmany);
	Kynetx::Memcached::mset_cache($skey,$json);
}

$logger->debug("and Many: ", sub {Dumper($andmany)});

$initial = $andmany->get_initial();

$logger->debug("Initial state (andmany): $initial");
$next = $andmany->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($andmany->is_final($next),0, "matching event, no transition");
$test_count++;

$logger->debug("Next: $next");

isnt($next,$initial,"Matching state, transition");
$test_count++;


$temp = $next;
$next = $andmany->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($andmany->is_final($next),0, "non matching event, no transition");
$test_count++;
$logger->debug("Next: $next");

is($next,$temp,"Repeat A, state remains the same");
$test_count++;

$temp = $next;
$next = $andmany->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($andmany->is_final($next),0, "non matching event, no transition");
$test_count++;
isnt($next,$temp,"Matching state, transition");
$test_count++;
$logger->debug("Next: $next");



$skey = "and1";
my $and1 = Kynetx::Memcached::check_cache($skey);
if (defined $and1  && ! $flush) {
	$and1 = Kynetx::Events::State->unserialize($and1);
} else {
	$and1 = mk_and($sm2,$sm3);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($and1);
	Kynetx::Memcached::mset_cache($skey,$json);
}

$skey = "and2";
my $and2 = Kynetx::Memcached::check_cache($skey);
if (defined $and2  && ! $flush) {
	$and2 = Kynetx::Events::State->unserialize($and2);
} else {
	$and2 = mk_and($sm1,$sm3);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($and2);
	Kynetx::Memcached::mset_cache($skey,$json);
}

$skey = "and3";
my $and3 = Kynetx::Memcached::check_cache($skey);
if (defined $and3  && ! $flush) {
	$and3 = Kynetx::Events::State->unserialize($and3);
} else {
	$and3 = mk_and($sm1,$sm2);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($and3);
	Kynetx::Memcached::mset_cache($skey,$json);
}


$skey = "andor1";
my $andor1 = Kynetx::Memcached::check_cache($skey);
#$andor1 = undef;
if (defined $andor1  && ! $flush ) {
	$andor1 = Kynetx::Events::State->unserialize($andor1);
} else {
	$andor1 = mk_or($and1,$and2);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($andor1);
	Kynetx::Memcached::mset_cache($skey,$json);
}

$logger->debug("--------------------------------------andor1: ", sub {Dumper($andor1)});


$logger->debug("New: ", sub {Dumper($andor1)});
#$andor1->optimize();
$logger->debug("Opt: ", sub {Dumper($andor1)});

$initial = $andor1->get_initial();

$logger->debug("Initial state (andor1): $initial");
$next = $andor1->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($andor1->is_final($next),0, "non matching event, no transition");
$test_count++;

isnt($next,$initial, "state has changed");
$test_count++;

$temp = $next;

$next = $andor1->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($andor1->is_final($next),0, "matching event, not final");
$test_count++;

is($next,$temp,"AB combo not valid, stay in state");
$test_count++;


is($next,$temp, "Not a matching transition, state remains same");
$test_count++;

$next = $andor1->next_state($next,$ev3,$rid,$session,$rule_name);
cmp_deeply($andor1->is_final($next),1, "matching event, final");
$test_count++;

#Log::Log4perl->easy_init($DEBUG);

$skey = "andor2";
my $andor2 = Kynetx::Memcached::check_cache($skey);
#$andor2 = undef;
if (defined $andor2  && ! $flush) {
	$andor2 = Kynetx::Events::State->unserialize($andor2);
} else {
	$andor2 = mk_or($andor1,$and3);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($andor2);
	Kynetx::Memcached::mset_cache($skey,$json);
}
$logger->debug("andor1: ", sub {Dumper($andor1)});
$logger->debug("andor2: ", sub {Dumper($andor2)});

$initial = $andor2->get_initial();

$logger->debug("Initial state (andor2): $initial");
$next = $andor2->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($andor2->is_final($next),0, "Matching event, not final");
$test_count++;

isnt($initial,$next,"Not initial");
$test_count++;

$temp = $next;

$next = $andor2->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($andor2->is_final($next),0, "Double event, not final");
$test_count++;

is($temp,$next,"Double event, no transition");
$test_count++;

$next = $andor2->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($andor2->is_final($next),1, "match event, is final");
$test_count++;


@sm_arry = ();
push(@sm_arry, $sm1);
push(@sm_arry, $sm2);
push(@sm_arry, $sm3);



$skey = "any2of3";
my $any = Kynetx::Memcached::check_cache($skey);
$any = undef;
if (defined $any) {
	$any = Kynetx::Events::State->unserialize($any);
} else {
	$any = mk_any(\@sm_arry,2);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($any);
	Kynetx::Memcached::mset_cache($skey,$json,36000);
}
$logger->debug("Any 2 of 3: ", sub {Dumper($any)});



$initial = $any->get_initial();

$logger->debug("Initial state (any): $initial");
$next = $any->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($any->is_final($next),0, "Matching event, not final");
$test_count++;

isnt($initial,$next,"Not initial");
$test_count++;

$temp = $next;

$next = $any->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($any->is_final($next),0, "Double event, not final");
$test_count++;

is($temp,$next,"Double event, no transition");
$test_count++;

$next = $any->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($any->is_final($next),1, "match event, is final");
$test_count++;


$skey = "repeat";
my $rpt = Kynetx::Memcached::check_cache($skey);
if (defined $rpt) {
	$rpt = Kynetx::Events::State->unserialize($rpt);
} else {
	$rpt = mk_repeat($sm1,3);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($rpt);
	Kynetx::Memcached::mset_cache($skey,$json,36000);
}

$logger->debug("SM repeat: ", sub {Dumper($rpt)});


$initial = $rpt->get_initial();

$logger->debug("Initial state (repeat): $initial");
$next = $rpt->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "First matching event, no transition");
$test_count++;



$logger->debug("Next state (repeat): $next f: ",$rpt->is_final($next));


$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "Second matching event, no transition");
$test_count++;
$logger->debug("Next state (2): $next f: ",$rpt->is_final($next));

$temp = $next;

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "Third matching event, is final");
$test_count++;
$logger->debug("Next state (3): $next f: ",$rpt->is_final($next));

my $event_list_name = $rule_name . ':event_list';

$rpt->reset_state($rid,$session,$rule_name,$event_list_name,$temp,$next);


$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "Third matching event, is final");
$test_count++;
$logger->debug("Next state (3): $next f: ",$rpt->is_final($next));

$next = $rpt->reset_state($rid,$session,$rule_name,$event_list_name,$temp,$next);

$next = $rpt->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "No match resets state");
$test_count++;

cmp_deeply($rpt->get_initial(),$next, "No match resets state to initial");
$test_count++;

$logger->debug("No match: $next f: ",$rpt->is_final($next));

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "new matching event, no transition");
$test_count++;
$logger->debug("New start: $next f: ",$rpt->is_final($next));


$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "2nd matching event, no transition");
$test_count++;
$logger->debug("2nd: $next f: ",$rpt->is_final($next));

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "3nd matching event, is final");
$test_count++;
$logger->debug("3nd: $next f: ",$rpt->is_final($next));

if ($rpt->is_final($next)) {
	$next = $rpt->reset_state($rid,$session,$rule_name,$event_list_name,$temp,$next);	
}

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "4th matching event, is final");
$test_count++;

if ($rpt->is_final($next)) {
	$next = $rpt->reset_state($rid,$session,$rule_name,$event_list_name,$temp,$next);	
}

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "5th matching event, is final");
$test_count++;

$logger->debug("3nd: $next f: ",$rpt->is_final($next));
Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

###############
#goto ENDY;
###############


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);
$next = Kynetx::Persistence::UserState::get_current_state($rid,$session,$rule_name);
$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "Fourth matching event, counter is reset");
$test_count++;

$next = $rpt->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "Other event, counter is reset");
$test_count++;



$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "First matching event, counter increments");
$test_count++;

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),0, "Second matching event, counter increments");
$test_count++;

$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "Third matching event, is final");
$test_count++;
my $final = $rpt->is_final($next);


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

my $sm_count = mk_count($sm1,3);
$initial = $sm_count->get_initial();
$logger->debug("Count sm: ", sub {Dumper($sm_count)});


$logger->debug("Count initial: ", sub {Dumper($initial)});
$next = $sm_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_count->is_final($next),0, "bFirst matching event, no transition");
$test_count++;

$next = $sm_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_count->is_final($next),0, "bsecond matching event, no transition");
$test_count++;

$next = $sm_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_count->is_final($next),0, "Ignore extraneous event, no transition");
$test_count++;


$logger->debug("Count initial: ", sub {Dumper($initial)});
$next = $sm_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_count->is_final($next),1, "bThird matching event, transition");
$test_count++;
$logger->debug("Final: ", $final);


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

## Compound count expression
#diag "mk_count A";
my $sm_count_A = mk_count($sm1,3);
$logger->debug("A: ", sub {Dumper($sm_count_A)});

#diag "mk_count B";
my $sm_count_B = mk_count($sm2,2);
$logger->debug("B: ", sub {Dumper($sm_count_B)});

#diag "A or B";
my $sm_compound_count = mk_or($sm_count_A,$sm_count_B);

$logger->debug("Compound (or) count state machine: ", sub {Dumper($sm_compound_count)});

$initial = $sm_compound_count->get_initial();
$logger->debug("Compound initial: ", sub {Dumper($initial)});
$next = $sm_compound_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;



$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match B, no transition");
$test_count++;

$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),1, "Compound match B, Transition");
$test_count++;

$logger->debug("Compound initial: ", sub {Dumper($next)});


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

$skey = "count3Aandcount2B";

$sm_compound_count = Kynetx::Memcached::check_cache($skey);
#$sm_compound_count = undef;
if (defined $sm_compound_count) {
	$sm_compound_count = Kynetx::Events::State->unserialize($sm_compound_count);
} else {
	$sm_compound_count = mk_and($sm_count_A,$sm_count_B);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm_compound_count);
	Kynetx::Memcached::mset_cache($skey,$json,36000);
}

# A and B
$logger->debug("Compound (and) count state machine: ", sub {Dumper($sm_compound_count)});

$initial = $sm_compound_count->get_initial();
$logger->debug("Compound initial: ", sub {Dumper($initial)});
$next = $sm_compound_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match B, no transition");
$test_count++;



$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),1, "Compound match B, A and B transition");
$test_count++;

$logger->debug("Current: $next");

Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);
# A then B
$skey = "AthenB";
$sm_compound_count = Kynetx::Memcached::check_cache($skey);
#$sm_compound_count = undef;
if (defined $sm_compound_count) {
	$sm_compound_count = Kynetx::Events::State->unserialize($sm_compound_count);
} else {
	$sm_compound_count = mk_then($sm_count_A,$sm_count_B);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm_compound_count);
	Kynetx::Memcached::mset_cache($skey,$json,36000);
}
$logger->debug("Compound (then) count state machine: ", sub {Dumper($sm_compound_count)});


$initial = $sm_compound_count->get_initial();
$logger->debug("Compound initial: ", sub {Dumper($initial)});
$next = $sm_compound_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match B, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match B, no transition");
$test_count++;



$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),1, "Compound match B, A then B transition");
$test_count++;

$logger->debug("Next: $next");

Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);
# A before B
$skey = "AbeforeB";
$sm_compound_count = Kynetx::Memcached::check_cache($skey);
#$sm_compound_count = undef;
if (defined $sm_compound_count) {
	$sm_compound_count = Kynetx::Events::State->unserialize($sm_compound_count);
} else {
	$sm_compound_count = mk_before($sm_count_A,$sm_count_B);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm_compound_count);
	Kynetx::Memcached::mset_cache($skey,$json,36000);
}
$logger->debug("Compound (before) count state machine: ", sub {Dumper($sm_compound_count)});


$initial = $sm_compound_count->get_initial();
$logger->debug("Compound initial: ", sub {Dumper($initial)});
$next = $sm_compound_count->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match B, no transition");
$test_count++;



$next = $sm_compound_count->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match A, A before B transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),0, "Compound match B, no transition");
$test_count++;


$next = $sm_compound_count->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_count->is_final($next),1, "Compound match B, Final state");
$test_count++;

$logger->debug("next: ", sub {Dumper($next)});

Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);
# x between A and B
my $sm_compound_between = mk_between($sm3, $sm_count_A, $sm_count_B);
$logger->debug("Compound (before) count state machine: ", sub {Dumper($sm_compound_between)});

$initial = $sm_compound_between->get_initial();
$next = $sm_compound_between->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev3,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match x, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match B, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),1, "Compound match B, x between A and B transition");
$test_count++;


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);
# x not between A and B
$sm_compound_between = mk_not_between($sm3, $sm_count_A, $sm_count_B);
$logger->debug("Compound (before) count state machine: ", sub {Dumper($sm_compound_between)});

$initial = $sm_compound_between->get_initial();
$next = $sm_compound_between->next_state($initial,$ev3,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "x, not between A and B");
$test_count++;


$next = $sm_compound_between->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match A, no transition");
$test_count++;

$next = $sm_compound_between->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),0, "Compound match B, no transition");
$test_count++;


$next = $sm_compound_between->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_between->is_final($next),1, "Compound match B, x between A and B transition");
$test_count++;


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);
# repeat 3 (a or b)
my $sm_compound_repeat = mk_repeat(mk_or($sm1,$sm2),3);
$logger->debug("Repeat 3 (a or b) state machine: ", sub {Dumper($sm_compound_repeat)});
$initial = $sm_compound_repeat->get_initial();

$next = $sm_compound_repeat->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match a(1), no transition");
$test_count++;

$next = $sm_compound_repeat->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match b(1), no transition");
$test_count++;

$next = $sm_compound_repeat->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),1, "match b(1), no transition");
$test_count++;


Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rule_name);

$skey = "repeat3aandb";

$sm_compound_repeat = Kynetx::Memcached::check_cache($skey);
#$sm_compound_repeat = undef;
if (defined $sm_compound_repeat) {
	$sm_compound_repeat = Kynetx::Events::State->unserialize($sm_compound_repeat);
} else {
	$sm_compound_repeat = mk_repeat(mk_and($sm1,$sm2),3);
	my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm_compound_repeat);
	Kynetx::Memcached::mset_cache($skey,$json,36000);
}

$logger->debug("Repeat 3 (a and b) state machine: ", sub {Dumper($sm_compound_repeat)});
$initial = $sm_compound_repeat->get_initial();

$next = $sm_compound_repeat->next_state($initial,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match a(1), no transition");
$test_count++;
$logger->debug("Current: $next");

$next = $sm_compound_repeat->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match b(1), no transition");
$test_count++;

$logger->debug("Current: $next");


$next = $sm_compound_repeat->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match b(1), no transition");
$test_count++;

$logger->debug("Current: $next");

$next = $sm_compound_repeat->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match b(1), no transition");
$test_count++;

$logger->debug("Current: $next");

$next = $sm_compound_repeat->next_state($next,$ev2,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),0, "match b(1), no transition");
$test_count++;

$logger->debug("Current: $next");
$next = $sm_compound_repeat->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($sm_compound_repeat->is_final($next),1, "match b(1), no transition");
$test_count++;




my $json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($sm1);
my $deserialized = Kynetx::Events::State->unserialize($json);
cmp_deeply($deserialized,$sm1,"Roundtrip serialization");
$test_count++;

# if we believe in our serialization, put our money...
$sm1 = $deserialized;

$initial = $sm2->get_initial();
$next = $sm2->next_state($initial, $ev2);

ok($sm2->is_final($next), "ev2 leads to final state");
$test_count++;
$next = $sm2->next_state($initial, $ev1);
ok($sm2->is_initial($next), "ev2 does not lead to initial state");
$test_count++;

is_deeply($ev2->get_vals($sm2->get_id()), ['is','a'], "we capture regexps");
$test_count++;

is_deeply($ev2->get_vars($sm2->get_id()), ['vv','bb'], "we get vars too");
$test_count++;

# test cloning
my $smc = $sm1->clone();

$initial = $smc->get_initial();

$next = $smc->next_state($initial, $ev1);
ok($smc->is_final($next), "ev1 leads to final state in clone");
$test_count++;

$next = $smc->next_state($initial, $ev2);
ok($smc->is_initial($next), "ev2 leads to initial state in clone");
$test_count++;

# do it again
$sm3 = mk_pageview_prim(qr/www.google.com/);
$initial = $sm3->get_initial();

$next = $sm3->next_state($initial, $ev3);
ok($sm3->is_final($next), "ev3 leads to final state");
$test_count++;

$next = $sm3->next_state($initial, $ev2);
ok($sm3->is_initial($next), "ev2 leads to initial state");
$test_count++;

# test join

my $join_sm = mk_pageview_prim(qr/www.google.com/);
$join_sm = $join_sm->add_state("foo",
			       [{"next" => $join_sm->get_singleton_final(),
				 "type" => "pageview",
				 "domain" => "web",
				 "test" => 'www.kynetx.com',
				}]);


$initial = $join_sm->get_initial();
$next = $join_sm->next_state("foo", $ev2);
ok($join_sm->is_final($next), "ev2 leads to final state");
$test_count++;


$next = $join_sm->next_state($initial, $ev3);
ok($join_sm->is_final($next), "ev3 leads to final state");
$test_count++;

is(@{ $join_sm->get_states() } + 0, 3, "join_sm has 3 states before join");
$test_count++;

my $ni = $join_sm->join_states("foo", $initial);
$join_sm->mk_initial($ni);

is(@{ $join_sm->get_states() } + 0, 2, "join_sm has 2 states after join");
$test_count++;

$initial = $join_sm->get_initial();
$next = $join_sm->next_state($initial, $ev2);
ok($join_sm->is_final($next), "ev2 leads to final state");
$test_count++;


$next = $join_sm->next_state($initial, $ev3);
ok($join_sm->is_final($next), "ev3 leads to final state");
$test_count++;



my ($n1, $n2, $n3);

# test mk_and
my $and_sm = mk_and($sm1, $sm3);
$initial = $and_sm->get_initial();

$n1 = $and_sm->next_state($initial, $ev1);
$n2 = $and_sm->next_state($n1, $ev3);
ok($and_sm->is_final($n2), "ev1,ev3 leads to final state in and");
$test_count++;

$n1 = $and_sm->next_state($initial, $ev3);
$n2 = $and_sm->next_state($n1, $ev1);
ok($and_sm->is_final($n2), "ev3,ev1 leads to final state in and");
$test_count++;

$n1 = $and_sm->next_state($initial, $ev3);
$n2 = $and_sm->next_state($n1, $ev2);
$n2 = $and_sm->next_state($n2, $ev2);
$n2 = $and_sm->next_state($n2, $ev2);
$n3 = $and_sm->next_state($n2, $ev1);
ok($and_sm->is_final($n3), "ev3,ev2...,ev1 leads to final state in and");
$test_count++;

$n1 = $and_sm->next_state($initial, $ev3);
$n2 = $and_sm->next_state($n1, $ev2);
$n2 = $and_sm->next_state($n2, $ev3);
$n2 = $and_sm->next_state($n2, $ev2);
$n3 = $and_sm->next_state($n2, $ev1);
ok($and_sm->is_final($n3), "ev3,ev2,ev3,ev2..,ev1 leads to final state in and");
$test_count++;

$next = $and_sm->next_state($initial, $ev2);
ok($and_sm->is_initial($next), "ev2 leads to initial state in and");
$test_count++;


# test mk_or

my $or_sm = mk_or($sm1, $sm3);
$initial = $or_sm->get_initial();

$n1 = $or_sm->next_state($initial, $ev1);
ok($or_sm->is_final($n1), "ev1 leads to final state in or");
$test_count++;

$n1 = $or_sm->next_state($initial, $ev3);
ok($or_sm->is_final($n1), "ev3 leads to final state in or");
$test_count++;

$n1 = $or_sm->next_state($initial, $ev2);
ok($or_sm->is_initial($n1), "ev2 leads to initial state in or");
$test_count++;

# test mk_before

my $b_sm = mk_before($sm1, $sm3);
$initial = $b_sm->get_initial();

$n1 = $b_sm->next_state($initial, $ev1);
$n2 = $b_sm->next_state($n1, $ev3);
ok($b_sm->is_final($n2), "ev1,ev3 leads to final state in before");
$test_count++;

$n1 = $b_sm->next_state($initial, $ev1);
$n2 = $b_sm->next_state($n1, $ev2);
$n3 = $b_sm->next_state($n2, $ev3);
ok($b_sm->is_final($n3), "ev1,ev2,ev3 leads to final state in before");
$test_count++;

$n1 = $b_sm->next_state($initial, $ev1);
$n2 = $b_sm->next_state($n1, $ev2);
$n2 = $b_sm->next_state($n1, $ev1);
$n2 = $b_sm->next_state($n1, $ev2);
$n2 = $b_sm->next_state($n1, $ev2);
$n2 = $b_sm->next_state($n1, $ev1);
$n3 = $b_sm->next_state($n2, $ev3);
ok($b_sm->is_final($n3), "ev1,ev2,ev3 leads to final state in before");
$test_count++;

$n1 = $b_sm->next_state($initial, $ev3);
$n2 = $b_sm->next_state($n1, $ev1);
ok(!$b_sm->is_final($n2), "ev3,ev1 does not lead to final state in before");
$test_count++;


# test mk_then

my $t_sm = mk_then($sm1, $sm3);
$initial = $t_sm->get_initial();

$n1 = $t_sm->next_state($initial, $ev1);
$n2 = $t_sm->next_state($n1, $ev3);
ok($t_sm->is_final($n2), "ev1,ev3 leads to final state in then");
$test_count++;

$n1 = $t_sm->next_state($initial, $ev1);
$n2 = $t_sm->next_state($n1, $ev2);
$n3 = $t_sm->next_state($n2, $ev3);
ok(!$t_sm->is_final($n3), "ev1,ev2,ev3 does not lead to final state in before");
$test_count++;

$n1 = $t_sm->next_state($initial, $ev1);
$n2 = $t_sm->next_state($n1, $ev2);
$n2 = $t_sm->next_state($n1, $ev1);
$n2 = $t_sm->next_state($n1, $ev2);
$n2 = $t_sm->next_state($n1, $ev2);
$n2 = $t_sm->next_state($n1, $ev1);
$n3 = $t_sm->next_state($n2, $ev3);
ok(!$t_sm->is_final($n3), "ev1,ev2,ev3 leads to final state in before");
$test_count++;

$n1 = $t_sm->next_state($initial, $ev3);
$n2 = $t_sm->next_state($n1, $ev1);
ok(!$t_sm->is_final($n2), "ev3,ev1 does not lead to final state in before");
$test_count++;


# test mk_between

my $btwn_sm = mk_between($sm1, $sm2, $sm3);

$initial = $btwn_sm->get_initial();

$n1 = $btwn_sm->next_state($initial, $ev2);
$n2 = $btwn_sm->next_state($n1, $ev1);
$n3 = $btwn_sm->next_state($n2, $ev3);
ok($btwn_sm->is_final($n3), "ev2,ev1,ev3 leads to final state in between");
$test_count++;

$n1 = $btwn_sm->next_state($initial, $ev2);
$n2 = $btwn_sm->next_state($n1, $ev4);
$n3 = $btwn_sm->next_state($n2, $ev3);
ok(!$btwn_sm->is_final($n3), "ev2,ev4,ev3 does not lead to final state in between");
$test_count++;

$n1 = $btwn_sm->next_state($initial, $ev2);
$n1 = $btwn_sm->next_state($n1, $ev4);
$n2 = $btwn_sm->next_state($n1, $ev1);
$n2 = $btwn_sm->next_state($n2, $ev4);
$n3 = $btwn_sm->next_state($n2, $ev3);
ok($btwn_sm->is_final($n3), "ev2,ev4,ev1,ev4,ev3 leads to final state in between");
$test_count++;


# test mk_not_between

my $nb_sm = mk_not_between($sm1, $sm2, $sm3);

$initial = $nb_sm->get_initial();

$n1 = $nb_sm->next_state($initial, $ev2);
$n2 = $nb_sm->next_state($n1, $ev3);
ok($nb_sm->is_final($n2), "ev2,ev3 leads to final state in not_between");
$test_count++;

$n1 = $nb_sm->next_state($initial, $ev2);
$n2 = $nb_sm->next_state($n1, $ev1);
$n3 = $nb_sm->next_state($n2, $ev3);
ok(!$nb_sm->is_final($n3), "ev2,ev1,ev3 does not lead to final state in not_between");
$test_count++;

$n1 = $nb_sm->next_state($initial, $ev1);
$n2 = $nb_sm->next_state($n1, $ev2);
$n3 = $nb_sm->next_state($n2, $ev3);
ok($nb_sm->is_final($n3), "ev1,ev2,ev3  lead to final state in not_between");
$test_count++;


my $ev5 = Kynetx::Events::Primitives->new();
$ev5->submit("#my_form");

#diag Dumper $ev5;

# test the pageview prim SMs
my $sm5 = mk_dom_prim("#my_form", '', '', 'submit');

#diag Dumper $sm5;

$initial = $sm5->get_initial();

$next = $sm5->next_state($initial, $ev5);
ok($sm5->is_final($next), "ev5 leads to final state");
$test_count++;

$next = $sm5->next_state($initial, $ev2);
ok($sm5->is_initial($next), "ev2 leads to initial state");
$test_count++;


# test the dom element pattern

my $ev6 = Kynetx::Events::Primitives->new();
$ev6->submit("#your_form");

my $sm6 = mk_dom_prim("#my_.*", '', '', 'submit');

#diag Dumper $sm6;

$initial = $sm6->get_initial();

$next = $sm6->next_state($initial, $ev5);
ok($sm6->is_final($next), "ev6 leads to final state");
$test_count++;

$next = $sm6->next_state($initial, $ev6);
ok($sm6->is_initial($next), "ev6 leads to initial state");
$test_count++;

ENDY:

done_testing($test_count);

1;


