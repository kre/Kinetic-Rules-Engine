package Kynetx::Scheduler;

# file: Kynetx/Scheduler.pm
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

use Log::Log4perl qw(get_logger :levels);
use Time::HiRes qw(time);
#use Storable qw(dclone);
use Clone qw(clone);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
	all => [
		qw(
		  )
	]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use Data::Dumper;
$Data::Dumper::Indent = 1;

sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $self     = {
		'rids'         => [],
		'current_rid'  => 0,
		'current_rule' => 0,
	};
	bless( $self, $class );    # consecrate
	return $self;
}

sub delete_rule {
	my $self     = shift;
	my $rid      = shift;
	my $rulename = shift;
	undef $self->{$rid}->{$rulename};
}

sub delete_rid {
	my $self = shift;
	my $rid  = shift;
	undef $self->{$rid};
}

sub annotate_task {
	my $self     = shift;
	my $rid      = shift;
	my $rulename = shift;
	my $task     = shift;
	my $var      = shift;
	my $val      = shift;
	#$self->{$rid}->{$rulename}->{$var} = $val;
	$task->{$var} = $val;
}

# return the next rule to execute
sub next {
	my $self = shift;
	my $r;

	my $logger = get_logger();

#	$logger->debug("[schedule] ", sub { Dumper $self});

	if ( scalar( @{ $self->{'rids'} } ) > $self->{'current_rid'} )
	{
		my $rid = $self->{'rids'}->[ $self->{'current_rid'} ];
		if ( defined $self->{$rid}
			&& scalar( @{ $self->{$rid}->{'rules'} } ) >
			$self->{'current_rule'} )
		{
			my $rn = $self->{$rid}->{'rules'}->[ $self->{'current_rule'} ];
			Log::Log4perl::MDC->put( 'rule', $rn );
			$logger->debug("Rule name: ", $rn);
			$r = $self->{$rid}->{$rn};
			if (defined $r && scalar(@$r)>0) {
				my $task = shift(@$r);
				Log::Log4perl::MDC->put( 'site', $rid);	
#				$logger->debug("Tasks: ",scalar(@$r));
				$logger->debug("Schedule iterator returning ",
					$task->{'rule'}->{'name'},
					" with current RID count ",
					$self->{'current_rid'},
					" and current rule count ",
					$self->{'current_rule'}
				);
	
#				$logger->debug("Found: (",$task->{'_ts'},") ",$task->{'req_info'}->{'num'});
				return $task;
			} else {
				$self->{'current_rule'}++;
				return $self->next();
			}
			
			


		}
		else {
			#$logger->debug("Moving to next RID");
			$self->{'current_rule'} = 0;
			$self->{'current_rid'}++;
			$self->delete_rid($rid);
			$r = $self->next();
		}

	}
	else {
		$logger->debug("Resetting schedule");
		$r                      = undef;
		$self->{'current_rule'} = 0;
		$self->{'current_rid'}  = 0;
		$self->{'rids'}         = [];
	}

	return $r;
}

#
# {ruleset =>
#  rules => [...]
#  rule_name => {req_info =>
#                vars =>
#                vals =>
#               }
#  req_info =>
# }

sub add {
	my $self     = shift;
	my $rid      = shift;
	my $rule     = shift;
	my $ruleset  = shift;
	my $req_info = shift;
	my $options  = shift;

	my $ridver = $options->{'ridver'} || 'prod';

	my $rulename = $rule->{'name'};

	my $logger = get_logger();
	#$logger->debug("Adding: ",$req_info->{'num'});
	$logger->debug("Adding task for: $rid.$ridver.$rulename");
	my $task = mk_task( $rid, $ridver, $ruleset, $rule, $req_info );

	# if the RID is alread a key, just add to the rule list
	if ( !defined $self->{$rid} ) {
		push( @{ $self->{'rids'} }, $rid );
		$self->{$rid} = {
			'rules'   => [$rulename],
			$rulename => [$task]
		};
	}
	else {
		push( @{ $self->{$rid}->{$rulename} }, $task );
		push( @{ $self->{$rid}->{'rules'} },   $rulename );
	}
#	$logger->debug("Schedule: ", sub { Dumper $self });
	return $task;

}

sub mk_task {
	my $rid      = shift;
	my $ver      = shift;
	my $ruleset  = shift;
	my $rule     = shift;
	my $req_info = shift || {};
	my $new_attrs = clone Kynetx::Request::get_attrs($req_info);
	# my $logger = get_logger();
	# $logger->debug("Attributes ", sub {Dumper $new_attrs});
	return {
		'ruleset'  => $ruleset,
		'rule'     => $rule,
		'rid'      => $rid,
		'ver'      => $ver,
		'req_info' => {"event_attrs" => $new_attrs},
		'_ts'      => time,
	};
}

sub get_ruleset {
	my $task = shift;
	return $task->{'ruleset'};
}

sub get_rule {

	my $task = shift;
	return $task->{'rule'};
}

sub get_rid {
	my $task = shift;
	return $task->{'rid'};
}

sub get_ver {
	my $task = shift;
	return $task->{'ver'};
}

sub set_ver {
	my $task = shift;
	my $ver = shift;
	$task->{'ver'} = $ver;
}

1;
