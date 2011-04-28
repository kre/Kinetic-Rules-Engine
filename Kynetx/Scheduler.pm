package Kynetx::Scheduler;

# file: Kynetx/Scheduler.pm
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
use Time::HiRes qw(time);
use Storable qw(dclone);
#use Clone qw(clone);

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

	if ( scalar( @{ $self->{'rids'} } ) > $self->{'current_rid'} )
	{
		my $rid = $self->{'rids'}->[ $self->{'current_rid'} ];
		if ( defined $self->{$rid}
			&& scalar( @{ $self->{$rid}->{'rules'} } ) >
			$self->{'current_rule'} )
		{
			my $rn = $self->{$rid}->{'rules'}->[ $self->{'current_rule'} ];
			$logger->debug("Rules name: ", $rn);
			$r = $self->{$rid}->{$rn};
			if (defined $r && scalar(@$r)>0) {
				my $task = shift(@$r);
				$logger->debug("Tasks: ",scalar(@$r));
				$logger->debug("Schedule iterator returning ",
					$task->{'rule'}->{'name'},
					" with current RID count ",
					$self->{'current_rid'},
					" and current rule count ",
					$self->{'current_rule'}
				);
				$logger->debug("Found: (",$task->{'_ts'},") ",$task->{'req_info'}->{'num'});
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

	my $rulename = $rule->{'name'};

	my $logger = get_logger();
	#$logger->debug("Adding: ",$req_info->{'num'});
	my $task = mk_task( $rid, $ruleset, $rule, $req_info );

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
	return $task;

}

sub mk_task {
	my $rid      = shift;
	my $ruleset  = shift;
	my $rule     = shift;
	my $req_info = shift || {};
	return {
		'ruleset'  => $ruleset,
		'rule'     => $rule,
		'rid'      => $rid,
		'req_info' => (dclone $req_info),
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

1;
