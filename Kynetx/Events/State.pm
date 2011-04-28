package Kynetx::Events::State;
# file: Kynetx/Events/State.pm
# file: Kynetx/Predicates/Referers.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Data::UUID;
use Kynetx::Json qw(:all);
use Clone;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"

our %EXPORT_TAGS = (all => [
qw(
mk_pageview_prim
mk_dom_prim
mk_gen_prim
mk_expr_prim
next_state
mk_and
mk_or
mk_before
mk_then
mk_between
mk_not_between
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my $S_TAG = "__state__";

sub new {
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $id = "SM-" . Data::UUID->new->create_str();
  my $self = {
	      "id"         => $id,
	      "initial"    => '_unknown_',
	      "final"      => {},
	      "transitions"  => {},
	     };
  bless($self, $class); # consecrate
  return $self;
}

sub TO_JSON {
    my $self = shift;
    my $logger = get_logger();
    my $hash;
    foreach my $key (keys %$self) {
        my $value = Clone::clone($self->{$key});
        $hash->{$key} = $value;
    }
    serialize_regexp_objects($hash);
    my $s = {
      #$S_TAG => JSON::XS::->new->allow_blessed(1)->utf8(1)->encode($hash)
      $S_TAG => JSON::XS::->new->allow_blessed(1)->encode($hash)
    };
    return $s;
}

sub serialize {
    my $self = shift;
    my $logger = get_logger();
    my $hash = $self->TO_JSON();
    return JSON::XS::->new->encode($hash);
}

sub unserialize {
    my $invocant = shift;
    my $logger = get_logger();
    my $class = ref($invocant) || $invocant;
    my ($json) = @_;
    return undef unless (defined $json);
    my $blob = $json;
    my $hash = JSON::XS::->new
            ->filter_json_single_key_object( $S_TAG => sub {
                my $s_state = $_[0];
                #my $s_struct = JSON::XS::->new->utf8(1)->decode($s_state);
                my $s_struct = JSON::XS::->new->decode($s_state);
                deserialize_regexp_objects($s_struct);
                bless($s_struct,$class);
            })->decode($json);
    if (! defined $hash || ref $hash eq "") {
        $logger->debug("Error attempting to unserialize State object, Source: ", sub {Dumper($json)});
        return undef;
    }

    return $hash;
}




sub add_state {
  my $self = shift;
  my($name, $transitions, $default) = @_;

  my $logger = get_logger();

  $logger->warn("adding a state that already exists") if defined $self->{'transitions'}->{$name};

  $self->{'transitions'}->{$name} = $transitions if defined $transitions;
  $self->{'__default__'}->{$name} = $default if defined $default;

  return $self;
}

sub clone {
  my $self = shift;

  my $logger = get_logger();

  $logger->trace("Cloning " . $self->get_id());


  my $state_map = {};
  # create all the new states and store in a map
  foreach my $s (@{$self->get_states()}) {
    $state_map->{$s} = Data::UUID->new->create_str();
  }

  # now build the clone
  my $nsm = Kynetx::Events::State->new();
  foreach my $s (@{$self->get_states()}) {

    my @nt;
    foreach my $t (@{$self->get_transitions($s)}) {
#        $logger->debug("working on: $t->{'next'} for $s");
	push @nt,
	  {"next" => $state_map->{$t->{'next'}},
	   "domain" => $t->{'domain'},
	   "type" => $t->{'type'},
	   "vars" => $t->{'vars'},
	   "test" => $t->{'test'},
	  };

    }
    $nsm->add_state($state_map->{$s},
		    \@nt,
		    $state_map->{$self->get_default_transition($s)});

    $nsm->mk_initial($state_map->{$s}) if $self->is_initial($s);
    $nsm->mk_final($state_map->{$s}) if $self->is_final($s);

  }
  return $nsm;
}

# This function makes some big assumptions.
#  1. That initial and final states are all that are being joined
#  2. That default transitions for initial states are always to the initial state.
#  2. That default transitions for final states are always to the final state.
sub join_states {
  my $self = shift;
  my ($s1, $s2) = @_;

  my $logger = get_logger();
  $logger->trace("Joining $s1 & $s2");

  my $ns = Data::UUID->new->create_str();

  my @nt;
  push(@nt, @{$self->get_transitions($s1)});
  push(@nt, @{$self->get_transitions($s2)});

  $self->add_state($ns,
		   \@nt,
		   $ns);

#  $logger->debug("New transitions added: ", Dumper $self->get_transitions($ns));

  foreach my $s (@{$self->get_states()}) {
    foreach my $t (@{$self->get_transitions($s)}) {
      $t->{'next'} = $ns if $t->{'next'} eq $s1 || $t->{'next'} eq $s2
    }
  }
  delete $self->{'transitions'}->{$s1};
  delete $self->{'transitions'}->{$s2};


  return $ns;
}

sub get_id {
  my $self = shift;

  return $self->{'id'};
}



sub mk_initial {
  my $self = shift;
  my $name = shift;

  my $logger = get_logger();

  $self->{'initial'} = $name;

  return $self;
}

sub get_initial {
  my $self = shift;
  return $self->{'initial'};
}

sub is_initial {
  my $self = shift;
  my $name = shift;

#   my $logger = get_logger();
#   $logger->debug("[is_initial] initial: ", $self->{'initial'});
#   $logger->debug("[is_initial] name: ", $name);

  return $self->{'initial'} eq $name;
}

sub mk_final {
  my $self = shift;
  my $name = shift;

  $self->{'final'}->{$name} = 1;

  return $self;
}

sub get_final {
  my $self = shift;
  my $name = shift;

  return $self->{'final'};
}

sub get_singleton_final {
  my $self = shift;

  my $logger = get_logger();

  my $final;
  my @finals = keys %{ $self->get_final() };
  if (@finals == 1) {
    $final = $finals[0];
  } else {
    $logger->warn("State machine " . $self->get_id() . " has more than one final state");
  }

  return $final;
}

sub is_final {
  my $self = shift;
  my $name = shift;

  if (defined $self->{'final'}->{$name}) {
    return $self->{'final'}->{$name};
  } else {
    return 0;
  }


}


sub get_states {
  my $self = shift;
  my @ks = keys %{ $self->{'transitions'} };
  return \@ks;
}

sub get_transitions {
  my $self = shift;
  my $state = shift;
  return $self->{'transitions'}->{$state} || undef;
}

sub get_default_transition {
  my $self = shift;
  my $name = shift;

  return $self->{'__default__'}->{$name};
}

sub set_default_transition {
  my $self = shift;
  my $name = shift;
  my $new = shift;

  $self->{'__default__'}->{$name} = $new;
}

# sub add_transition {
#   my $self = shift;
#   my($name, $token, $new) = @_;

#   my $logger = get_logger();

#   $logger->warn("adding a transition that already exists") if defined $self->{'transitions'}->{$name}->{$token};

#   $self->{'transitions'}->{$name}->{$token} = $new;
# }


#-------------------------------------------------------------------------
# calculate next state
#-------------------------------------------------------------------------

# $eval_funcs is a hash of transition application functions keyed
# by primitive type.
# transition application functions should take an event obj and a transition and
# return a bool if the application of the transition function in the transition
# returns true as well as an array of values returns from the match
my $eval_funcs = {};

sub next_state {
  my $self = shift;
  my($state, $event) = @_;
  my $logger = get_logger();

  # reset if needed
  $state = $self->get_initial() unless defined $self->get_transitions($state);

#  $logger->debug("Starting state: ", $state);

  my $transitions = $self->get_transitions($state);
  $logger->trace("Transistions: ", sub {Dumper($transitions)});

  my $next = $self->get_default_transition($state);
  foreach my $t (@{ $transitions }) {
    $logger->trace("Transition type: ",$t->{'type'}, " Event type: ", $event->get_type());
    my ($match,$vals) = match($event, $t);
    $logger->trace("Trans vars ", sub { Dumper $t->{'vars'} });
    if ($match) {
      $next = $t->{'next'};
      $event->set_vars( $self->get_id(), $t->{'vars'});
      $event->set_vals($self->get_id(), $vals);
    }
  }
  return $next;

}

sub match {
  my($event, $transition) = @_;
  my $ttype = $transition->{'type'};
  my $etype = $event->get_type();
  my $tdomain = $transition->{'domain'};
  my $edomain = $event->get_domain();
  my $logger = get_logger();
  $logger->trace("Looking for a ",sub {Dumper($ttype)});
  $logger->trace("In event of : ",sub {Dumper($etype)});

  return 0 unless $tdomain eq $edomain;
  if (defined $ttype && $ttype eq 'expression') {
		$logger->debug("Need to eval the statement to check against $ttype");
		return expr_eval($event,$transition);
  }
  return 0 unless $event->isa($transition->{'type'});
  
  if (defined $eval_funcs->{$event->get_type()}) {
    return $eval_funcs->{$event->get_type()}->($event, $transition);
  } else {
    return gen_event_eval($event, $transition);
  }
}


#-------------------------------------------------------------------------
# primitives
#-------------------------------------------------------------------------

sub mk_prim {
  my ($test, $vars, $domain, $type) = @_;
  my $sm = Kynetx::Events::State->new();
  my $s1 = Data::UUID->new->create_str();
  my $s2 = Data::UUID->new->create_str();
  my $logger = get_logger();
  $logger->trace("Make primitive: ", sub {Dumper($test)});

  $sm->mk_initial($s1);
  $sm->mk_final($s2);

  $sm->add_state($s1,
		 [{"next" => $s2,
		   "type" => $type,
		   "domain" => $domain,
		   "test" => $test,
		   "vars" => $vars,
		  }],
		 $s1
		);

  $sm->add_state($s2,
		 [],
		 $s2
		);

  return $sm;
}

#-------------------------------------------------------------------------
# pageview
#-------------------------------------------------------------------------

sub mk_pageview_prim {
  my ($pattern, $vars) = @_;

  return mk_prim($pattern,
		 $vars,
		 'web',
		 'pageview'
		);
}

sub pageview_eval {
  my ($event, $t) = @_;

  sub test {my $url = shift;
	    my $pattern = shift;
	    my $captures = [];
	    my $logger = get_logger();
	    $logger->trace("Url: $url; Pattern: $pattern");

	    if(@{$captures} = $url =~ /$pattern/) {
	      return (1, $captures);
	    } else {
	      return (0, $captures);
	    }
	  };

  return test($event->url(), $t->{'test'});
}
$eval_funcs->{'pageview'} = \&pageview_eval;

#-------------------------------------------------------------------------
# submit, click, change
#-------------------------------------------------------------------------

sub mk_dom_prim {
  my ($sm_elem, $sm_pattern, $vars, $type) = @_;

  return mk_prim([$sm_elem, $sm_pattern],
		 $vars,
		 'web',
		 $type
		);
}

sub dom_eval {
  my ($event, $t) = @_;

  my $test = sub {my $event_elem = shift;
		  my $sm_elem = shift;
		  my $url = shift;
		  my $pattern = shift;
		  my $logger = get_logger();


		  $logger->trace("Evaluating event $event_elem against SM $sm_elem");

		  my $req_info = $event->get_req_info();
		  my $form_data = $req_info->{'KOBJ_form_data'} if $req_info->{'KOBJ_form_data'};
#		  if ($event_elem eq $sm_elem && $url =~ /$pattern/) {
		  if ($event_elem eq $sm_elem) {
		    return(1, $form_data);
		  } else {
		    return(0, []);
		  }
	  };

  return $test->($event->element(), $t->{'test'}->[0], $event->url(), $t->{'test'}->[1]);
}
$eval_funcs->{'submit'} = \&dom_eval;
$eval_funcs->{'click'} = \&dom_eval;
$eval_funcs->{'change'} = \&dom_eval;
$eval_funcs->{'update'} = \&dom_eval;
$eval_funcs->{'dblclick'} = \&dom_eval;

sub mk_expr_prim {
  my ($domain, $op, $vars, $expr) = @_;
  my $logger = get_logger();
  $logger->trace("Op: ", sub {Dumper($op)});
  $logger->trace("Vars: ", sub {Dumper($vars)});
  $logger->trace("Expr: ", sub {Dumper($expr)});

  return mk_prim($expr,
		 $vars,
		 $domain,
		 $op
		);	
}

sub mk_gen_prim {
  my ($domain, $op, $vars, $filters) = @_;
  my $logger = get_logger();
  $logger->trace("Op: ", sub {Dumper($op)});
  $logger->trace("Vars: ", sub {Dumper($vars)});
  $logger->trace("Filter: ", sub {Dumper($filters)});

  return mk_prim($filters,
		 $vars,
		 $domain,
		 $op
		);
}

## Event Expression
sub expr_eval {
	my ($event,$t) = @_;
	my $logger = get_logger();
	my $req_info = $event->get_req_info();
	my $rule_env = Kynetx::Environments::event_rule_env($event);
	my $session = undef;
	#$logger->debug("Request info is: ", sub {Dumper($req_info)});
#	my $type = $event->get_type();
#	my ($domain,$eventid) = split(/:/,$type);
#	my $rule_env = Kynetx::Environments::extend_rule_env($eventid,1,$init_rule_env);
	$logger->trace("Rule env: ", sub {Dumper($rule_env)});	
	my $expressions = $t->{'test'};
	my $capKeys = Clone::clone($t->{'vars'});
	my $capVals = [];
	foreach my $expr (@$expressions) {
		$logger->trace("Expression: ", sub {Dumper($expr)});
		my $v = Kynetx::Expressions::den_to_exp(
			Kynetx::Expressions::eval_expr($expr, $rule_env,,$req_info,$session));
		$logger->trace("Expression evaled: ", sub {Dumper($v)});
		if (defined $v && $v ne "__undef__" && !($v =~ /^0$/)) {
			push(@$capVals,$v);
			my $key = shift @{$capKeys};
			if ($key) {
#				if (ref $v eq "array") {
#					$rule_env = Kynetx::Environments::extend_rule_env($key,@{$v},$rule_env);
#				} else {
					$rule_env = Kynetx::Environments::extend_rule_env($key,$v,$rule_env);
#				}
				
			}
		} else {
			return (0,$capVals);
		}
	}
	return (1,$capVals);
		
}

# this creates a target from then params names in the event spec &
# a pattern from the associated pattern and then captures the values
sub gen_event_eval {
  my ($event, $t) = @_;

  my $logger = get_logger();
  my $captures = [];

  my $delimeter = 'XQX';
  my $req_info = $event->get_req_info();

  $logger->trace("Match transition: ", sub {Dumper $t});

  my $filters = $t->{'test'};

  # initializing these to delimeter ensures we'll get a match if no
  # pattern and target
  my $pattern;
  my $target;
  foreach my $filter (@{ $filters }) {
    $target = $req_info->{$filter->{'type'}};
    $pattern = $filter->{'pattern'};
    # $logger->debug("-----------------------------------------------------");
    # $logger->debug("filter: ", sub {Dumper $filter});
    # $logger->debug("Target: $target; Pattern: $pattern");
    my @this_captures;
    if(@this_captures = $target =~ /$pattern/) {
#      $logger->debug("Captures: ($1)", sub {Dumper @this_captures}); 
      push (@{$captures}, @this_captures) if $1; #$1 not set if no capture
    } else {
      # if any of these are false, we return 0 and the empty capture list
      return (0, []);
    }
  }
  $logger->debug("Final captures: ", sub {Dumper $captures});
  return (1, $captures);
}


#-------------------------------------------------------------------------
# composite state machines
#-------------------------------------------------------------------------
sub mk_and {
  my($osm1, $osm2) = @_;

  my $logger = get_logger();


  $logger->trace("Composing (and) " . $osm1->get_id() . " & " . $osm2->get_id());

  # we don't want this modifying the original SM
  my $sm1 = $osm1->clone();
  my $sm2 = $osm2->clone();
  my $sm3 = $sm2->clone();
  my $sm4 = $sm1->clone();

  my $nsm = Kynetx::Events::State->new();

  foreach my $sm ($sm1, $sm2, $sm3, $sm4) {
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
  }

  my $ni = $nsm->join_states($sm1->get_initial(), $sm3->get_initial());
  $nsm->mk_initial($ni);
  $logger->trace("new initial state $ni");


  $nsm->join_states($sm1->get_singleton_final(), $sm2->get_initial());
  $nsm->join_states($sm3->get_singleton_final(), $sm4->get_initial());

  my $nf = $nsm->join_states($sm2->get_singleton_final(),
			     $sm4->get_singleton_final());
  $nsm->mk_final($nf);
  $logger->trace("new final state $nf");

  return $nsm;
}

sub mk_or {
  my($osm1, $osm2) = @_;

  my $logger = get_logger();

  # we don't want this modifying the original SM
  my $sm1 = $osm1->clone();
  my $sm2 = $osm2->clone();

  my $nsm = Kynetx::Events::State->new();
  foreach my $sm ($sm1, $sm2) {
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
  }

  my $ni = $nsm->join_states($sm1->get_initial(), $sm2->get_initial());
  $nsm->mk_initial($ni);
  $logger->trace("new initial state $ni");

  my $nf = $nsm->join_states($sm1->get_singleton_final(),
			     $sm2->get_singleton_final());

  $nsm->mk_final($nf);
  $logger->trace("new final state $nf");

  return $nsm;
}

sub mk_before {
  my($osm1, $osm2) = @_;

  my $logger = get_logger();

  # we don't want this modifying the original SM
  my $sm1 = $osm1->clone();
  my $sm2 = $osm2->clone();

  my $nsm = Kynetx::Events::State->new();
  foreach my $sm ($sm1, $sm2) {
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
  }

  $nsm->mk_initial($sm1->get_initial());
  $nsm->join_states($sm1->get_singleton_final(), $sm2->get_initial());
  $nsm->mk_final($sm2->get_singleton_final());

  return $nsm;
}

sub mk_then {
  my($osm1, $osm2) = @_;

  my $logger = get_logger();

  # we don't want this modifying the original SM
  my $sm1 = $osm1->clone();
  my $sm2 = $osm2->clone();

  my $nsm = Kynetx::Events::State->new();
  foreach my $sm ($sm1, $sm2) {
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
  }

  $nsm->mk_initial($sm1->get_initial());

  my $mid = $nsm->join_states($sm1->get_singleton_final(), $sm2->get_initial());
  # default transition goes back instead of looping
  $nsm->set_default_transition($mid, $sm1->get_initial());

  $nsm->mk_final($sm2->get_singleton_final());

  return $nsm;
}

# a between b & c
sub mk_between {
  my($oa, $ob, $oc) = @_;

  my $logger = get_logger();

  # we don't want this modifying the original SM
  my $a = $oa->clone();
  my $b = $ob->clone();
  my $c = $oc->clone();

  my $nsm = Kynetx::Events::State->new();
  foreach my $sm ($a, $b, $c) {
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
  }

  $nsm->mk_initial($b->get_initial());
  $nsm->join_states($b->get_singleton_final(), $a->get_initial());
  $nsm->join_states($a->get_singleton_final(), $c->get_initial());
  $nsm->mk_final($c->get_singleton_final());

  return $nsm;
}

# a not between b & c
sub mk_not_between {
  my($oa, $ob, $oc) = @_;

  my $logger = get_logger();

  # we don't want this modifying the original SM
  my $a = $oa->clone();
  my $b = $ob->clone();
  my $c = $oc->clone();

  my $nsm = Kynetx::Events::State->new();
  foreach my $sm ($a, $b, $c) {
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
  }


  my $mid = $nsm->join_states($b->get_singleton_final(), $c->get_initial());

  $mid = $nsm->join_states($mid, $a->get_initial());

  $mid = $nsm->join_states($a->get_singleton_final(), $b->get_initial());

  $nsm->mk_initial($mid);
  $nsm->mk_final($c->get_singleton_final());

  return $nsm;
}



1;
