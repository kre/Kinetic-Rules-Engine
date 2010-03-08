#!/usr/bin/perl -w 

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

use Kynetx::Test qw/:all/;
use Kynetx::Events::State qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


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


my $sm = Kynetx::Events::State->new();
$sm->add_state("i", {"a"=>"p"},"q");
$sm->add_state("p", {"a"=>"p"}, "q");
$sm->add_state("q", {"a"=>"p"}, "q");
$sm->mk_initial("i");
$sm->mk_final("p");

is($sm->next_state("i", "a"), "p", "i->p for a");
is($sm->next_state("i", "b"), "q", "i->q for other");
is($sm->next_state("p", "a"), "p", "p->p for a");
is($sm->next_state("p", "b"), "q", "p->q for other");
is($sm->next_state("q", "a"), "p", "q->p for a");
is($sm->next_state("q", "b"), "q", "q->q for other");
$test_count += 6;

ok($sm->is_final("p"), "p is final");
ok($sm->is_initial("i"), "i is initial");
ok(!$sm->is_initial("p"), "p is not initial");
ok(!$sm->is_initial("q"), "q is not initial");
ok(!$sm->is_final("q"), "q is not final");
ok(!$sm->is_final("i"), "i is not final");
$test_count += 6;

is_deeply($sm->get_states(), ["p", "q", "i"], "Get the states");
$test_count++;

is_deeply($sm->get_transitions("i"), {"a" => "p", "__default__" => "q"}, "transitions from i");
is_deeply($sm->get_transitions("p"), {"a" => "p", "__default__" => "q"}, "transitions from p");
is_deeply($sm->get_transitions("q"), {"a" => "p", "__default__" => "q"}, "transitions from q");
$test_count += 3;


sub sm_and {
  my($sm1, $sm2) = @_;

  my $sm1_states = $sm1->get_states();
  my $sm2_states = $sm2->get_states();

  my $nsm = Kynetx::Events::State->new();

  foreach my $s1 (@{$sm1_states}) {
    foreach my $s2 (@{$sm2_states}) {
      $nsm->add_state("$s1$s2");

      my $sm1_outs = $sm1->get_transitions($s1); # {"a" => "i", "b" => "y"} 
      my $sm2_outs = $sm2->get_transitions($s2);

      # calculate intersection of inputs
      my @t;
      foreach my $sm1_token (keys %{$sm1_outs}) {
	push @t, $sm1_token if defined $sm2_outs->{$sm1_token};
      }
      
      foreach my $token (@t) {
	$nsm->add_transition("$s1$s2", $token, $sm1_outs->{$token}.$sm1_outs->{$token});
      }

      $nsm->mk_initial("$s1$s2") if $sm1->is_initial($s1) && $sm2->is_initial($s2);
      $nsm->mk_final("$s1$s2") if $sm1->is_final($s1) && $sm2->is_final($s2);

    }
  }
  return $nsm;
}

my $sm2 = Kynetx::Events::State->new();
$sm->add_state("i", {"b"=>"p"},"q");
$sm->add_state("p", {"b"=>"p"}, "q");
$sm->add_state("q", {"b"=>"p"}, "q");
$sm->mk_initial("i");
$sm->mk_final("p");

my $sm3 = sm_and($sm, $sm2);


done_testing($test_count);


1;


