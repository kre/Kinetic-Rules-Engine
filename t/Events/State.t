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
#use warnings;
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
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Events::State qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Events::Primitives qw/:all/;


use Kynetx::FakeReq qw/:all/;

my $logger = get_logger();

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $test_count = 0;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';
my $session = Kynetx::Test::gen_session($r, $rid);

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $ev1 = Kynetx::Events::Primitives->new();
$ev1->pageview($my_req_info->{'caller'});

my $ev2 = Kynetx::Events::Primitives->new();
$ev2->pageview("http://www.kynetx.com/this/is/a/bad/url.html");

my $ev3 = Kynetx::Events::Primitives->new();
$ev3->pageview("http://www.google.com/");

my $ev4 = Kynetx::Events::Primitives->new();
$ev4->pageview("http://www.yahoo.com/");

# test the pageview prim SMs
my $sm1 = mk_pageview_prim(qr/www.windley.com/);
my $sm2 = mk_pageview_prim(qr#/(..)/(a)#, ['vv','bb']);
my $sm3 = mk_pageview_prim(qr/www.google.com/);

my $initial = $sm1->get_initial();
my $next;
#my $next = $sm1->next_state($initial, $ev1);
#ok($sm1->is_final($next), "ev1 leads to final state");
#$test_count++;
#
#$next = $sm1->next_state($initial, $ev2);
#ok($sm1->is_initial($next), "ev2 does not lead to initial state");
#$test_count++;

my $rpt = mk_repeat($sm1,3);
my $copy = Kynetx::Events::State::clone($rpt);
$logger->debug("SM repeat: ", sub {Dumper($rpt)});
#$logger->debug("SM repeat clone: ", sub {Dumper($copy)});




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


$next = $rpt->next_state($next,$ev1,$rid,$session,$rule_name);
cmp_deeply($rpt->is_final($next),1, "Third matching event, is final");
$test_count++;
$logger->debug("Next state (3): $next f: ",$rpt->is_final($next));

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

my $skey = "count3Aandcount2B";

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
# repeat 3 (a and b)
#my $tmp = mk_and($sm1,$sm2);
#my $sm_compound_repeat = mk_repeat($tmp,3);
#$logger->debug("(a and b) state machine: ", sub {Dumper($tmp)});

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


############
#goto ENDY;
############




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


