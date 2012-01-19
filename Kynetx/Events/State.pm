package Kynetx::Events::State;
# file: Kynetx/Events/State.pm
# file: Kynetx/Predicates/Referers.pm
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
use strict;
#use warnings;
no warnings qw(uninitialized);

use Log::Log4perl qw(get_logger :levels);

use Data::UUID;
use Kynetx::Json qw(:all);
use Kynetx::Environments qw(empty_rule_env);
use Kynetx::Persistence::UserState qw(
	get_current_state
	set_current_state
	delete_current_state
);
use Kynetx::Persistence qw(:all);
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
mk_repeat
mk_count
mk_any
mk_and_n
mk_or_n
mk_before_n
mk_after_n
mk_then_n
reset_state
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
        $logger->trace("Error attempting to unserialize State object, Source: ", sub {Dumper($json)});
        return undef;
    }

    return $hash;
}




sub add_state {
  my $self = shift;
  my($name, $transitions, $default) = @_;

  my $logger = get_logger();
#  $logger->debug("Add state: ");
#  $logger->debug("Name: ", $name);
#  $logger->debug("Transitions: ", sub {Dumper($transitions)});
#  $logger->debug("Default: ", sub {Dumper($default)});

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
        $logger->trace("working on: $t->{'next'} for $s");
		push @nt,
		  {"next" => $state_map->{$t->{'next'}},
		   "domain" => $t->{'domain'},
		   "type" => $t->{'type'},
		   "vars" => $t->{'vars'},
		   "test" => $t->{'test'},
		   "counter" => $t->{'counter'},
		   "count" => $t->{'count'}
		  };
    }
	if ($self->is_null($s)) {
		$nsm->set_null($state_map->{$s});
	}	
	
	if (defined $self->{'__timeframe__'}->{$s}) {
		my $seconds = $self->{'__timeframe__'}->{$s}->{'seconds'};
		my $start = $state_map->{$self->{'__timeframe__'}->{$s}->{'start'}};
		$nsm->{'__timeframe__'}->{$state_map->{$s}} = {
			'seconds' => $seconds,
			'start' => $start
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

sub optimize {
	my $self = shift;
	my $logger = get_logger();
	
	# Check all the states
	my $initial = $self->get_initial();
	my @final_set = keys %{$self->get_final()};
	my @set_of_states = ();
	$self->optimize_transitions($initial);
	
	$self->follow($initial,\@set_of_states);
		
	foreach my $s (@{$self->get_states()}) {
		my @tmp = ($s);
		#  Check for default states that can't be reached from $initial
		if (! Kynetx::Util::has(\@set_of_states,\@tmp)) {
			$logger->debug("UNREACHABLE $s");
  			delete $self->{'__default__'}->{$s};  
  			delete $self->{'transitions'}->{$s};
  			next;			
		}
		
	}
		
}

sub optimize_transitions {
	my $self = shift;
	my $state = shift;
	my $pruned = shift;
	my $logger = get_logger();
	if (defined $pruned) {
		# add all the transitions from the pruned path to this
		foreach my $t (@{$self->get_transitions($pruned)}) {
			$self->add_transition($state,$t);
		}		
	}
	my $hash = {};
	foreach my $t (@{$self->get_transitions($state)}) {
		my $sig = _tsig($t);
		$logger->trace("Sig: $sig");
		if ($hash->{$sig}) {
			$logger->trace("  Duped sig");
			if ($hash->{$sig}->{'next'} eq $t->{'next'}) {
				$logger->trace("Destination dupe: ", $t->{'next'});
			} else {
				$logger->trace("Add filters of ",$t->{'next'});
				$self->optimize_transitions($hash->{$sig}->{'next'},$t->{'next'});
			}
		} else {
			$hash->{$sig} = $t;
		}
	}
	my @new_t = values (%{$hash});
	my $count =  scalar (@{$self->get_transitions($state)}) - scalar (@new_t);
	if ($count > 0) {
		$logger->debug("$count transitions pruned");
		$self->{'transitions'}->{$state} = \@new_t;		
	}
	
}



sub follow {
	my $self = shift;
	my $start = shift;
	my $s_of_s = shift;
	my $logger= get_logger();
	my @temp = ($start);
	if (Kynetx::Util::has($s_of_s,\@temp)) {
		# seen this state, don't loop
		return;
	} else {
		push(@$s_of_s, $start);
		foreach my $t (@{$self->get_transitions($start)}) {
			if (defined $t->{'next'}) {
				$self->follow($t->{'next'},$s_of_s);
			}
		}
	}
	
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
  $logger->trace("Substituting: $ns");
  $logger->trace("Transitions for $s1 ",sub {Dumper($self->get_transitions($s1))});
  $logger->trace("Transitions for $s2 ",sub {Dumper($self->get_transitions($s2))});
  my @nt;
  my $nt1 = $self->get_transitions($s1);
  $logger->trace("$s1");
#  for my $t (@$nt1) {
#  	$logger->trace($t->{'next'}, " ", sub {Dumper($t->{'test'})});
#  }
  my $nt2 = $self->get_transitions($s2);  
  $logger->trace("$s2");
#  for my $ta (@$nt2) {
#  	$logger->trace($ta->{'next'}, " ", sub {Dumper($ta->{'test'})});
#  }
  push(@nt, @{$nt1});
  push(@nt, @{$nt2});
  
  $self->add_state($ns,
		   \@nt,
		   $ns);

  $logger->trace("New transitions added: ", Dumper $self->get_transitions($ns));  
  

  # rename any transitions that were joined
  foreach my $s (@{$self->get_states()}) {
    foreach my $t (@{$self->get_transitions($s)}) {
      if ($t->{'next'} eq $s1 || $t->{'next'} eq $s2){
      	$t->{'next'} = $ns;
      }
    }    
  }

  # Explicit null rename
  foreach my $n (keys %{$self->{'null'}}) {
  	$logger->trace("Null: $n");
  	my $def_t = $self->get_default_transition($n);
  	if ($s1 eq $def_t || $s2 eq $def_t) {
  		$self->set_default_transition($n,$ns);
  	}
  }
  
  # Timeframe merge/rename
  $logger->trace("Timeframe: ",  sub {Dumper($self->{'__timeframe__'})});
  foreach my $tf (keys %{$self->{'__timeframe__'}}) {
  	$logger->trace("Check: $tf for join match");
  	my $seconds = $self->{'__timeframe__'}->{$tf}->{'seconds'};
  	my $start = $self->{'__timeframe__'}->{$tf}->{'start'};
  	if ($start eq $s1 || $start eq $s2) {
  		$logger->trace("Start matches: $start");
  		$start = $ns;
  		$self->{'__timeframe__'}->{$tf}->{'start'} = $start;
  	} elsif ($tf eq $s1 || $tf eq $s2) {
  		$logger->trace("Final matches: $tf");
  		$self->{'__timeframe__'}->{$ns} = {
  			'start' => $start,
  			'seconds' => $seconds
  		};
  	}
  }

  delete $self->{'__timeframe__'}->{$s1};
  delete $self->{'__timeframe__'}->{$s2};
  delete $self->{'__default__'}->{$s1};
  delete $self->{'__default__'}->{$s2};  
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

sub is_null {
	my $self = shift;
	my $sname = shift;
	if ($self->{"null"}->{$sname}) {
		return $self->{"null"}->{$sname};
	} else {
		return 0;
	}
}

sub is_timed {
	my $self = shift;
}

sub mk_final {
  my $self = shift;
  my $name = shift;

  $self->{'final'}->{$name} = 1;

  return $self;
}

sub set_null {
	my $self = shift;
	my $name = shift;
	$self->{'null'}->{$name} = 1;
}

sub set_timeframe {
	my $self = shift;
	my $name = shift;
	my $timeframe = shift;
	$self->{'__timeframe__'}->{$name} = $timeframe;
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

sub is_start_time {
	my $self = shift;
	my $state = shift;
	if (defined $self->{'__timeframe__'}) {
		foreach my $tf (keys %{$self->{'__timeframe__'}}) {
		  	my $start = $self->{'__timeframe__'}->{$tf}->{'start'};
		  	if ($start eq $state) {
		  		return 1;
		  	}
		}
	}
	return 0;
}

sub is_end_time {
	my $self = shift;
	my $state = shift;
	if (defined $self->{'__timeframe__'}) {
		if (defined $self->{'__timeframe__'}->{$state}) {
			return $self->{'__timeframe__'}->{$state};
		}
	}
	return 0;
}


sub get_states {
  my $self = shift;
  my @ks = keys %{ $self->{'transitions'} };
  return \@ks;
}

sub get_transitions {
  my $self = shift;
  my $state = shift;
  my $logger = get_logger();
  #$logger->trace("Existing transitions for state: $state");
  #$logger->trace("$state: ", sub {Dumper($self->{'transitions'}->{$state})});
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

sub add_transition {
	my $self = shift;
	my $state = shift;
	my $transition = shift;
	my $logger = get_logger();
	$logger->trace("Adding: ", sub {Dumper($transition)});
	push(@{$self->{'transitions'}->{$state}},$transition);	
}

sub timeframe {
	my $self = shift;
	my $seconds = shift;
	my $initial = $self->get_initial();
	my $final = $self->get_singleton_final();
	my $timing = {
		'start' => $initial,
		'seconds' => $seconds
	};
	$self->{'__timeframe__'}->{$final} = $timing;
	
}

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
	my($state, $event, $rid, $session, $rulename) = @_;
	my $logger = get_logger();
	
	# reset if needed
	$state = $self->get_initial() unless defined $self->get_transitions($state);
	
	$logger->trace("Current: $state");
	$logger->trace("This state machine: ", sub {Dumper($self)});

	my $transitions = $self->get_transitions($state);
	$logger->trace("Transistions: ", sub {Dumper($transitions)});
	my $repeat = 0;
	my $next = $self->get_default_transition($state);
	foreach my $t (@{ $transitions }) {  
		my $next_transition = $t->{'next'};
		my $isnull = $self->is_null($next_transition);
		my $null_transition;		
		if ($isnull) {
			$null_transition = $self->get_transitions($next_transition)->[0];
			my $trans_type = $null_transition->{'domain'};
			if ($trans_type eq 'repeat') {
				$repeat = $null_transition->{'counter'};
			}
		}
		$logger->trace("This transition: ", sub {Dumper($t)});
		$logger->trace("Filter: ", $t->{'test'});		
		my ($match,$vals) = match($event, $t);
		if ($match) {
			my $start_clock;
			my $end_clock;
			if ($self->is_start_time($state)) {
				$logger->debug("Begin timed transaction");
				$start_clock = "__timeframe__";
			}
	  		if ($isnull) {
	    		$logger->trace("THIS IS A NULL TRANSITION!");	    		
				$logger->trace("Transition options: ", sub{Dumper($null_transition)});
				my $counterid = $null_transition->{'counter'};
				my $count = $null_transition->{'count'};
				my $agg_op = $null_transition->{'vars'}->{'agg_op'};
				my @agg_var = ();
				foreach my $var (@{$null_transition->{'vars'}->{'vars'}}) {
					push(@agg_var,$var->{'val'});
				}
				unless (defined $agg_op) {
					if (defined $start_clock) {
						$vals = ["__timeframe__"] 
					} else {
						$vals = ["__null__"]
					}
				};
	    		my $counter = Kynetx::Persistence::UserState::push_aggregator($rid,$session,$rulename,$counterid,$vals);
				$logger->trace("match val: ", sub {Dumper($vals)});
				$logger->trace("Counter struct: ", sub {Dumper($counter)});
				my $stime = $self->is_end_time($null_transition->{'next'});
				my @iters = check_time($counter->{$counterid},$stime);
				$logger->trace("Grouped transition iters: ", sub {Dumper(@iters)});							
				if (scalar (@iters) >= $count) {
					$logger->trace("Transition to next state is a null so process immediately $next");
					$next = $self->get_transitions($next_transition);
					if (defined $agg_op) {						
						my $agg_val = aggregate($agg_op,\@iters);
						$logger->trace("aggs: ", sub{Dumper($agg_val)});
	      				$event->set_vars( $self->get_id(), \@agg_var);
	      				$event->set_vals($self->get_id(), [$agg_val]);
					}
					
					if ($null_transition->{'domain'} eq 'repeat') {
						Kynetx::Persistence::UserState::repeat_group_counter($rid,$session,$rulename,$counterid,$state,$next_transition);
						$logger->trace("Shift counter: $counterid");
					} else {
						Kynetx::Persistence::UserState::reset_group_counter($rid,$session,$rulename,$counterid);						
						$logger->trace("Reset counter: $counterid");
					}
					$next = $next->[0]->{'next'};
					return $next;
				} else {
					$logger->trace("Group match current: $state");
					$logger->debug("Need ", sub{Dumper($count - scalar (@iters))}, " more $next_transition(s)");
					$next = $self->get_default_transition($next_transition);
					return $next;
				}
	       	} else {
	    		$logger->debug("NORMAL TRANSITION");
	    		if (defined $start_clock) {
	    			my $counter = Kynetx::Persistence::UserState::push_aggregator($rid,$session,$rulename,$state,[$start_clock]);
	    			#$logger->debug("Set start time for $state: ", sub {Dumper($counter)});
	    		}
	      		$next = $t->{'next'};
	      		if (my $timeframe = $self->is_end_time($next)) {
	      			my $etime = DateTime->now->epoch();
	      			#$logger->debug("Is end time $etime: ", sub {Dumper($timeframe)});
	      			my $start = $timeframe->{'start'};
	      			#$logger->debug("Start is $start");
	      			my $num = $timeframe->{'seconds'};
	      			my $thing = Kynetx::Persistence::UserState::get_timer_start($rid,$session,$rulename,$start);
	      			#$logger->debug("Counter: ",  sub {Dumper($thing)});
	      			my $stime = $thing->[0]->{'timestamp'};
	      			my $diff = $etime - $stime;
	      			#$logger->debug("Elapsed: $diff");
	      			
	      			if ($diff > $num) {
	      				$logger->debug("Failed timeframe, needed $num or less: got $diff");
	      				Kynetx::Persistence::UserState::reset_group_counter($rid,$session,$rulename,$start);
	      				return $self->get_default_transition($start);
	      			}
	      		}
	      		$event->set_vars( $self->get_id(), $t->{'vars'});
	      		$event->set_vals($self->get_id(), $vals);
	      		return $next;
	    	}
		}
	}
	if ($repeat) {
		$logger->trace("Repeat transition found but no match");
		$logger->trace("NO TRANSITION");
		Kynetx::Persistence::UserState::reset_group_counter($rid,$session,$rulename,$repeat);
	}
	$logger->trace("Repeat: $repeat");
	$logger->trace("Current: $state");
#	$logger->trace("M Match: $tmatch");
	$logger->trace("Next: $next");
	return $next;

}

sub check_time {
	my ($count_array,$timeframe) = @_;
	my $min_time;
	my $logger = get_logger();
	if (defined $timeframe && ref $timeframe eq "HASH") {
		$min_time = DateTime->now->epoch - $timeframe->{'seconds'};
	} else {
		$min_time = 0;
	};
	my @rarray = ();
	$logger->trace("MIN TIME: $min_time");
	foreach my $instance (@{$count_array}) {
		if ($instance->{'timestamp'} >= $min_time) {
			$logger->trace(" ts: ", $instance->{'timestamp'});
			push (@rarray,$instance->{'val'})
		} else {
			$logger->trace(" miss: ", $instance->{'timestamp'});
		}
	}
	$logger->trace("array: ", sub {Dumper(@rarray)});
	return @rarray;
	
}

sub aggregate {
	my ($op,$array) = @_;
	if ($op eq "sum") {
		return _sum($array);
	} elsif ($op eq "min") {
		return _min($array);
	} elsif ($op eq "max") {
		return _max($array);
	} elsif ($op eq "avg") {
		return _avg($array);
	} elsif ($op eq "push") {
		return $array;
	}
	
}

sub _sum {
	my ($array) = @_;
	my $sum = 0;
	foreach my $elem (@{$array}) {
		$sum += $elem;
	}
	return $sum;
}

sub _max {
	my ($array) = @_;
	my $max = undef;
	foreach my $elem (@{$array}) {
		if (! defined $max) {
			$max = $elem;
		} elsif ($elem > $max) {
			$max = $elem;
		}
	}
	return $max;
	
}

sub _min {
	my ($array) = @_;
	my $min = undef;
	foreach my $elem (@{$array}) {
		if (! defined $min) {
			$min = $elem;
		} elsif ($elem < $min) {
			$min = $elem;
		}
	}
	return $min;
	
}

sub _avg {
	my ($array) = @_;
	my $sum = _sum($array);
	my $num = scalar(@{$array});
	return $sum / $num;	
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
  return 0 unless $event->isa($ttype, $tdomain);

  if (defined $ttype && $ttype eq 'expression') {
		$logger->trace("Need to eval the statement to check against $ttype");
		return expr_eval($event,$transition);
  }
  
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

# simple pattern match against default target is now a special case of the 
# gen_event_eval
sub pageview_eval {
  	my ($event, $t) = @_;
  	my $logger = get_logger();
	my $filter = $t->{'test'};
	$logger->trace("pageview eval: ", sub {Dumper($filter)});
	if (ref $filter ne "ARRAY") {
		# Make a filter expression from the old form pageview test
		my $pattern = $t->{'test'};
		my $type = 'url';
		$t->{'test'} = [{
			'pattern' => $pattern,
			'type' => $type
		}]
	}

  	return gen_event_eval($event,$t);
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

		  my $captures = [];
		  my @this_captures;
		  if(@this_captures = $event_elem =~ /$sm_elem/) {
	   #      $logger->debug("Captures: ($1)", sub {Dumper @this_captures}); 
		    push (@{$captures}, @this_captures) if $1; #$1 not set if no capture
		  } else {
		    # if any of these are false, we return 0 and the empty capture list
		    return (0, []);
		  }
#    $logger->trace("Final captures: ", sub {Dumper $captures});
		  return (1, $captures);

		  # if ($event_elem eq $sm_elem) {
		  #   return(1, $form_data);
		  # } else {
		  #   return(0, []);
		  # }
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


  my $filters = $t->{'test'};
  my $op = $t->{'type'};

  # initializing these to delimeter ensures we'll get a match if no
  # pattern and target
  my $pattern;
  my $target;
  foreach my $filter (@{ $filters }) {  
  	my $filter_type= $filter->{'type'};
  	# Allow different defaults for diff event types
  	$logger->trace("Req info: ", sub{Dumper($req_info)});
  	if ($op eq 'pageview') {
  		if ($filter_type eq 'default') {
  			$filter_type = 'url';  			
  		} 
  		$target = $event->{$filter_type};  		
  	} else {
  		$target = $req_info->{$filter_type};
  	}
    $pattern = $filter->{'pattern'};
    $logger->debug("Target: $target; Pattern: $pattern");
    my @this_captures;
    if(@this_captures = $target =~ /$pattern/) {
      push (@{$captures}, @this_captures) if $1; #$1 not set if no capture
    } else {
      # if any of these are false, we return 0 and the empty capture list
      return (0, []);
    }
  }
  $logger->trace("Final captures: ", sub {Dumper $captures});
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
    # add each grouped transition
    foreach my $n (keys %{$sm->{'null'}}) {
    	$nsm->set_null($n);
    }
    
    # add timed transition
    foreach my $tf (keys %{$sm->{'__timeframe__'}}) {
    	$nsm->set_timeframe($tf, $sm->{'__timeframe__'}->{$tf});
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
  $nsm->optimize();

  return $nsm;
}

sub mk_or {
  my($osm1, $osm2) = @_;

  my $logger = get_logger();

  # we don't want this modifying the original SM
  my $sm1 = $osm1->clone();
  $logger->trace("Original A: ", sub {Dumper($osm1)});
  $logger->trace("Cloned A: ",sub {Dumper($sm1)});
  my $sm2 = $osm2->clone();
  #$logger->trace("Cloned B: ",sub {Dumper($sm2)});

  my $nsm = Kynetx::Events::State->new();
  foreach my $sm ($sm1, $sm2) {
    # add each state transition
    foreach my $s (@{$sm->get_states()}) {
      $nsm->add_state($s,
		      $sm->get_transitions($s),
		      $sm->get_default_transition($s)
		    );
    }
    # add each grouped transition
    foreach my $n (keys %{$sm->{'null'}}) {
    	$nsm->set_null($n);
    }
    # add timed transition
    foreach my $tf (keys %{$sm->{'__timeframe__'}}) {
    	$nsm->set_timeframe($tf, $sm->{'__timeframe__'}->{$tf});
    }
  }

  my $ni = $nsm->join_states($sm1->get_initial(), $sm2->get_initial());
  
  $nsm->mk_initial($ni);

  my $nf = $nsm->join_states($sm1->get_singleton_final(),
			     $sm2->get_singleton_final());

  $nsm->mk_final($nf);
  $nsm->optimize();
  return $nsm;
}

sub add_grouped_state {
	my $self = shift;
	my ($sm, $s) = @_;
	if ($sm->{'group'}->{$s}) {
		my ($num,$type) = @{$sm->{'group'}->{$s}};
		$self->add_group($type,$s,$num);
	}
}

sub add_group {
	my $self = shift;
	my ($type,$s,$num) = @_;
	my $logger = get_logger();
	if ($type eq 'count') {
		$self->add_count($s,$num);
	} elsif ($type eq 'repeat') {
		$self->add_repeat($s,$num);
	} else {
		$logger->warn("Unknown group type ($type)");
	}
	
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
    # add each grouped transition
    foreach my $n (keys %{$sm->{'null'}}) {
    	$nsm->set_null($n);
    }
    # add timed transition
    foreach my $tf (keys %{$sm->{'__timeframe__'}}) {
    	$nsm->set_timeframe($tf, $sm->{'__timeframe__'}->{$tf});
    }
  }

  $nsm->mk_initial($sm1->get_initial());

  my $mid = $nsm->join_states($sm1->get_singleton_final(), $sm2->get_initial());
  # default transition goes back instead of looping
  $nsm->set_default_transition($mid, $sm1->get_initial());

  $nsm->mk_final($sm2->get_singleton_final());

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
    # add each grouped transition
    foreach my $n (keys %{$sm->{'null'}}) {
    	$nsm->set_null($n);
    }
    # add timed transition
    foreach my $tf (keys %{$sm->{'__timeframe__'}}) {
    	$nsm->set_timeframe($tf, $sm->{'__timeframe__'}->{$tf});
    }
  }

  $nsm->mk_initial($sm1->get_initial());
  $nsm->join_states($sm1->get_singleton_final(), $sm2->get_initial());
  $nsm->mk_final($sm2->get_singleton_final());

  return $nsm;
}

#-------------------------------------------------------------------------
# arity
#-------------------------------------------------------------------------
sub mk_and_n {
	my ($sm_array) = @_;
	my $logger = get_logger();
	my $num = scalar(@{$sm_array});
	return mk_any($sm_array,$num);
}


sub mk_or_n {
	my ($sm_array) = @_;
	my $logger = get_logger();
	my $nsm = $sm_array->[0];
	for (my $i = 1; $i < scalar(@{$sm_array}); $i++) {
		my $c = $nsm->clone();
		$nsm = mk_or($c,$sm_array->[$i]);
	}
	return $nsm;
}

sub mk_before_n {
	my ($sm_array) = @_;
	my $logger = get_logger();
	my $nsm = $sm_array->[0];
	for (my $i = 1; $i < scalar(@{$sm_array}); $i++) {
		my $c = $nsm->clone();
		$nsm = mk_before($c,$sm_array->[$i]);
	}
	return $nsm;
}

sub mk_after_n {
	my ($sm_array) = @_;
	my $logger = get_logger();
	my @rev = reverse (@$sm_array);
	return mk_before_n(\@rev);
}

sub mk_then_n {
	my ($sm_array) = @_;
	my $logger = get_logger();
	my $nsm = $sm_array->[0];
	for (my $i = 1; $i < scalar(@{$sm_array}); $i++) {
		my $c = $nsm->clone();
		$nsm = mk_then($c,$sm_array->[$i]);
	}
	return $nsm;
}

#-------------------------------------------------------------------------
# group state machines
#-------------------------------------------------------------------------
sub mk_any {
	my ($sm_array,$num,$agg) = @_;
	my $logger = get_logger();
	# make an array of inidices
	my @set = Kynetx::Util::any_matrix(scalar(@$sm_array),$num);
	$logger->trace("ANY $num of N (indices combinations): ", sub {Dumper(@set)});
	my @or_array = ();
	for my $x (@set) {
		my $xi = pop @$x;
		my $nsm = $sm_array->[$xi];
		foreach my $y (@$x) {
			my $nsma = $nsm->clone();
			$nsm = mk_before($nsma,$sm_array->[$y]);
		}
		push(@or_array,$nsm);
	}
	$logger->trace("Ors: ", sub {Dumper(@or_array)});
	my $nsm = pop @or_array;
	for my $a_sm (@or_array) {
		my $nsmp = $nsm->clone();
		$nsm = mk_or($nsmp,$a_sm);
	}
  	$nsm->optimize();
	return $nsm;
}

sub mk_count {
	my ($osm,$num,$agg) = @_;
	my $logger = get_logger();
	$logger->trace("-----Make count state machine-----");
	
	my $sm = $osm->clone();
	my $null = mk_null('count',$num,$agg);

	
	my $nsm = Kynetx::Events::State->new();
	foreach my $sm ($sm,$null)	{
		foreach my $s (@{$sm->get_states()}) {
			$nsm->add_state($s,
				$sm->get_transitions($s),
				$sm->get_default_transition($s)
				);
		}
	}
	$nsm->mk_initial($sm->get_initial());	
	
	my $mid = $nsm->join_states($sm->get_singleton_final(),$null->get_initial());
	
	$nsm->set_default_transition($mid,$sm->get_initial());
	$nsm->mk_final($null->get_singleton_final());	
	$nsm->set_null($mid);
	
	return $nsm;
}

sub mk_repeat {
	my ($osm,$num,$agg) = @_;
	my $logger = get_logger();
	
	my $sm = $osm->clone();
	my $null = mk_null('repeat',$num);
	
	my $nsm = Kynetx::Events::State->new();
	foreach my $sm ($sm,$null)	{
		foreach my $s (@{$sm->get_states()}) {
			$nsm->add_state($s,
				$sm->get_transitions($s),
				$sm->get_default_transition($s)
			);
		}
	}
	$nsm->mk_initial($sm->get_initial());
	my $mid = $nsm->join_states($sm->get_singleton_final(),$null->get_initial());
	$nsm->set_default_transition($mid,$sm->get_initial());
	$nsm->mk_final($null->get_singleton_final());
	$nsm->set_null($mid);
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
    # add each grouped transition
    foreach my $n (keys %{$sm->{'null'}}) {
    	$nsm->set_null($n);
    }
    # add timed transition
    foreach my $tf (keys %{$sm->{'__timeframe__'}}) {
    	$nsm->set_timeframe($tf, $sm->{'__timeframe__'}->{$tf});
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
    # add each grouped transition
    foreach my $n (keys %{$sm->{'null'}}) {
    	$nsm->set_null($n);
    }
    # add timed transition
    foreach my $tf (keys %{$sm->{'__timeframe__'}}) {
    	$nsm->set_timeframe($tf, $sm->{'__timeframe__'}->{$tf});
    }
  }


  my $mid = $nsm->join_states($b->get_singleton_final(), $c->get_initial());

  $mid = $nsm->join_states($mid, $a->get_initial());

  $mid = $nsm->join_states($a->get_singleton_final(), $b->get_initial());

  $nsm->mk_initial($mid);
  $nsm->mk_final($c->get_singleton_final());

  return $nsm;
}


sub mk_null {
	my ($source,$count,$vars) = @_;
	$source = $source || "null";
	my $sm = Kynetx::Events::State->new();
  	my $s1 = Data::UUID->new->create_str();
  	my $s2 = Data::UUID->new->create_str();
  	my $counter = Data::UUID->new->create_str();
  	my $logger = get_logger();
  	$logger->trace("Make Null Transition: ");

  	$sm->mk_initial($s1);
  	$sm->mk_final($s2);
  	
  	my $struct = {"next" => $s2,
  			"type" => "__null__",
  			"domain" => $source
  	};
  	
  	if ($count) {
  		$struct->{'count'} = $count
  	}
  	
  	if (defined $vars) {
  		$struct->{'vars'} = $vars;
  	}
  	
  	$struct->{'counter'} = $counter;
  	
  	$sm->add_state($s1,
  		[$struct],
  		$s1
  	);
  	
  	$sm->add_state($s2,
  		[],
  		$s2
  	);
  	
  	return $sm;
	
}

sub add_repeat {
  my $self = shift;
  my $name = shift;
  my $num = shift;
  $self->{'group'}->{$name} = [$num,'repeat'];
  
  return $self;
}


sub add_count {
  my $self = shift;
  my $name = shift;
  my $num = shift;
  $self->{'group'}->{$name} = [$num,'count'];
  
  return $self;
}


sub _tsig {
	my ($transition) = @_;
	my $logger = get_logger();
	$logger->trace("transition (sig): ", sub {Dumper($transition)});
	#start with simple filter match 
	my @sigarray = ();
	if (ref $transition eq "HASH") {
		push(@sigarray,$transition->{'domain'});
		push(@sigarray,$transition->{'type'});
		if (defined $transition->{'counter'}) {
			push(@sigarray,$transition->{'counter'})
		}
		if (ref $transition->{'test'} eq "ARRAY") {
			foreach my $test (@{$transition->{'test'}}) {
				my $pattern;
				if (ref $test eq "HASH") {
					$pattern = YAML::XS::Dump $test->{'pattern'};
				} else {
					$pattern = YAML::XS::Dump $test;
				}
				push(@sigarray,$pattern);
			}
		} else {
			push(@sigarray, YAML::XS::Dump $transition->{'test'});
		}
	} else {
		$logger->warn("Non hash transition unexpected");
	}
	return join("__",@sigarray);
	
}

sub reset_state {
	my $self = shift;
	my ($rid,$session,$rulename, $event_list_name,$current, $next) = @_;
	my $logger = get_logger();
	
	if ($self->is_final($next)) {
		$logger->trace("Final state: $next");
		my $transitions = $self->get_transitions($current);
		
		$logger->trace("transitions: $current", sub {Dumper($transitions)});
		if (defined $self->{'null'}) {
			# If the state machine doesn't have a group transition, don't
			# bother checking the userstate
			my $ee = Kynetx::Persistence::UserState::get_event_env($rid,$session,$rulename);
			$logger->trace("Reset grouped state: ", sub {Dumper($ee)});
			if (defined $ee->{'__repeat__'}->{$current}) {
				$logger->trace("Transition through null just happened: ",$ee->{'__repeat__'}->{$current});
				Kynetx::Persistence::UserState::set_current_state($rid,$session,$rulename,$current);
				return $current;
			}
		}
		Kynetx::Persistence::UserState::delete_current_state($rid,$session,$rulename);
		delete_persistent_var("ent",$rid,$session,$event_list_name);
	} else {
		$logger->warn("[reset_state] $next is not final");
	}
	
	return $self->get_initial();
	
}

1;
