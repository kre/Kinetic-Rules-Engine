#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;
use diagnostics;

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
use Kynetx::Events::State qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Events::Primitives qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $test_count = 0;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

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

my $initial = $sm1->get_initial();

my $next = $sm1->next_state($initial, $ev1);
ok($sm1->is_final($next), "ev1 leads to final state");
$test_count++;

$next = $sm1->next_state($initial, $ev2);
ok($sm1->is_initial($next), "ev2 does not lead to initial state");
$test_count++;

# test the pageview prim SMs
my $sm2 = mk_pageview_prim(qr#/(..)/(a)#, ['vv','bb']);

$initial = $sm2->get_initial();
$next = $sm2->next_state($initial, $ev2);

ok($sm2->is_final($next), "ev2 leads to final state");
$test_count++;

$next = $sm2->next_state($initial, $ev1);
ok($sm2->is_initial($next), "ev2 does not lead to initial state");
$test_count++;

is_deeply($ev2->get_vals(), ['is','a'], "we capture regexps");
$test_count++;

is_deeply($ev2->get_vars(), ['vv','bb'], "we get vars too");
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
my $sm3 = mk_pageview_prim(qr/www.google.com/);
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
my $sm5 = mk_submit_prim("#my_form");

#diag Dumper $sm5;	    

$initial = $sm5->get_initial();

$next = $sm5->next_state($initial, $ev5);
ok($sm5->is_final($next), "ev5 leads to final state");
$test_count++;

$next = $sm5->next_state($initial, $ev2);
ok($sm5->is_initial($next), "ev2 does not lead to initial state");
$test_count++;



done_testing($test_count);

1;


