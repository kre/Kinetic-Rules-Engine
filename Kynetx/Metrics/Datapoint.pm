package Kynetx::Metrics::Datapoint;

# file: Kynetx/Datasets.pm
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
use utf8;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;
use Data::Dumper;
use Data::UUID;
use Storable qw(dclone);

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

#use Kynetx::JavaScript qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Rids qw/:all/;
use Kynetx::MongoDB;
use Benchmark ':hireswallclock';
no warnings "redefine";

our $AUTOLOAD;

use constant COLLECTION => "metrics";
use constant INTERVAL   => 1;
use constant NUMPOINTS => 1000;
use constant PVAL_LIMIT => 25;

my %fields = (
	vars      => undef,
	vals      => undef,
	series    => undef,
	timestamp => undef,
	tags      => undef,
	id        => undef,
	proc     => undef,
	mhostname => undef,
	count     => 0,
	eid       => undef,
	rid		  => undef,
	rulename  => undef,
	path	  => undef,
	event	  => undef,
	token	  => undef,
  memfree => undef
);

sub new {
	my $class  = shift;
	my $logger = get_logger();
	my $self   = { %fields, };
	bless( $self, $class );

	# general initializations
	my $c = Kynetx::Configure::get_config('METRICS');
	#$logger->debug( "Config: ", sub { Dumper($c) } );
	my $ug = new Data::UUID;
	$self->{'id'}        = $ug->create_str();
	$self->{'timestamp'} = DateTime->now->epoch();
	$self->{"series"}    = "__undef__";
	$self->{"proc"}     = $c->{'PROC'};
	$self->{"mhostname"} = $c->{'HOSTNAME'};
	@{ $self->{"vars"} } = ();
	@{ $self->{"vals"} } = ();
	@{ $self->{"tags"} } = ();
	my ($var_hash) = @_;

	if ( defined $var_hash ) {
		if ( ref $var_hash eq 'HASH' ) {
			$logger->trace( "data hash: ", sub { Dumper($var_hash) } );
			foreach my $varkey ( keys %$var_hash ) {
				$logger->trace( "var: ", $varkey, "->", $var_hash->{$varkey} );
				if ( exists $self->{$varkey} ) {
					$self->{$varkey} = $var_hash->{$varkey};
				}
			}
		}
		else {
			die "Initialization failed. Args not passed as a hash";
		}
	}
	return $self;
}

sub AUTOLOAD {
	my $self   = shift;
	my $logger = get_logger();
	my $type   = ref($self)
	  or die "($AUTOLOAD): $self is not an object";
	my $name = $AUTOLOAD;
	$name =~ s/.*://;
	unless ( exists $self->{$name} ) {
		$logger->trace("$name not permitted in class $type");
		return;
	}

	if (@_) {
		my $obj = shift;
		if ( ref $obj ne "" ) {
			return $self->{$name} = dclone $obj;
		}
		else {
			return $self->{$name} = $obj;
		}

	}
	else {
		return $self->{$name};
	}
}

sub DESTROY { }

sub start_timer {
	my $self   = shift;
	my $logger = get_logger();
	$self->{"_start"} = new Benchmark;
}

sub isStarted {
	my $self = shift;
	if ( defined $self->{"_start"} ) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isStopped {
	my $self = shift;
	if ( defined $self->{"_stop"} ) {
		return 1;
	}
	else {
		return 0;
	}
}

sub stop_timer {
	my $self   = shift;
	my $logger = get_logger();
	if ( defined $self->{"_start"} ) {
		my $stop = new Benchmark;
		my $diff = timediff( $stop, $self->{"_start"} );
		#$logger->debug( "Diff: ", timestr( $diff, 'all' ) );
		my @vars =
		  ( 'realtime', 'usertime', 'systime', 'cusertime', 'csystime', 'cpu' );
		my @vals = @$diff;
		$self->push( \@vars, \@vals );
	}
	else {
		$logger->debug(
			"Stop timer called but no start time exists, using epoch time");
		my $start = $self->timestamp();
		my $stop  = DateTime->now->epoch();
		my $diff  = $stop - $start;
		$self->push( 'etime', $diff );
	}
	$self->{"_stop"} = 1;
}

sub push {
	my $self = shift;
	my ( $var, $val ) = @_;
	my $logger = get_logger();
	#$logger->debug( "Var: ", sub { Dumper($var) } );
	#$logger->debug( "Val: ", sub { Dumper($val) } );
	if ( ref $var eq 'ARRAY' && ref $val eq 'ARRAY' ) {
		my $l1   = scalar(@$var);
		my $l2   = scalar(@$val);
		my @vars = @{ $self->{"vars"} };
		my @vals = @{ $self->{"vals"} };
		if ( $l1 == $l2 ) {
			my $i;
			for ( $i = 0 ; $i < $l1 ; $i++ ) {
				push( @vars, _schop($var->[$i]) );
				push( @vals, _schop($val->[$i]) );
			}
			$self->{"vars"} = \@vars;
			$self->{"vals"} = \@vals;
		}
	}
	elsif ( ref $var eq '' && ref $val eq '' ) {
		push( @{ $self->{"vars"} }, _schop($var) );
		push( @{ $self->{"vals"} }, _schop($val) );
	}

}

sub _schop {
  my ($str) = @_;
  $str = "$str";
  my $len = length($str);
  my $slen = ($len > PVAL_LIMIT) ? PVAL_LIMIT : $len;
  return substr $str, 0,$slen;  
}

sub get_metric {
	my $self = shift;
	my ($key) = @_;
	my $hash;
	my $i = 0;
	foreach my $var ( @{ $self->{"vars"} } ) {
		$hash->{$var} = $self->{"vals"}->[ $i++ ];
	}
	if ( $key eq 'timestamp' && $hash->{$key} == undef ) {
		return $self->timestamp;
	}

	return $hash->{$key};
}



# Create a separate entry for counts that might be
# stuck in a looped process
sub tick {
	my $self   = shift;
	my ($flush) = @_;
	my $logger = get_logger();
	$self->{'count'} += 1;
	my $mongoid    = $self->{'mid'};
	if ( defined $mongoid ) {
		my $now  = DateTime->now->epoch();
		my $last_up = $self->{'last_updated'};
		if ( !defined $last_up || ( $now > $last_up + INTERVAL ) || defined $flush) {
			$logger->debug("Update mongo ", $self->count);
			my $mid = MongoDB::OID->new("value" => $mongoid);
			my $c      = Kynetx::MongoDB::get_collection(COLLECTION);
			my $result = $c->update({"_id" => $mid}, {'$set' => {'count' => $self->{'count'}}});
			#$logger->debug("Result: ", sub {Dumper($result)})
			$self->last_updated($now);
		} else {
			#$logger->debug("Wait to update");
		}

	}
	else {
		my $id = 'eid';
		if ( !defined $self->eid ) {
			my $val = $self->{'proc'} . '-' . int( rand(10000) );
			$self->eid($val);
			$logger->debug("EID: $val");
		}
		my $rid  = $self->get_metric('rid')      || '__undef__';
		my $rule = $self->get_metric('rulename') || '__undef__';
		my $obj = {
			"series"   => $self->{"series"} . "-ticks",
			"hostname" => $self->{"mhostname"},
			"proc"     => $self->{'proc'},
			"count"    => $self->{'count'},
			"eid"      => $self->{'eid'},
			'rid'      => $rid,
			'rulename' => $rule,
			'tags'	   => $self->{"tags"},
			'ts'	   => $self->{"timestamp"},
			"path"	   => $self->{'path'}
		};
		my $status = _update($obj);
		$logger->debug( "Tick insert: ", sub { Dumper($status) } );
		$logger->debug( "Tick ref: ", ref  $status );
		if (ref $status eq "MongoDB::OID") {
			$self->{'mid'} = $status->to_string;
		}		
		$self->{'last_updated'} = DateTime->now->epoch();
		
	}

	return $self->{'count'};
}



sub store {
	my $self = shift;
	my $hash;
	my $i = 0;
	foreach my $var ( @{ $self->{"vars"} } ) {
		$hash->{$var} = $self->{"vals"}->[ $i++ ];
	}
	my $obj = {
		"metric"   => $hash,
		"ts"       => $self->{"timestamp"},
		"series"   => $self->{"series"},
		"tags"     => $self->{"tags"},
		"hostname" => $self->{"mhostname"},
		"proc"     => $self->{'proc'},
		"count"    => $self->{'count'},
		"eid"      => $self->{'eid'},
		"rid"	   => $self->{'rid'},
		"rulename" => $self->{'rulename'},
		"path"	   => $self->{'path'},
		"token"    => $self->{'token'},
		"memfree"  => $self->{'memfree'}
	};
	if (defined $self->{'event'}) {
		$obj->{"eventdomain"} = $self->{'event'}->{'domain'};
		$obj->{"eventtype"} = $self->{'event'}->{'type'};
	}
	_update($obj);
}

sub stop_and_store {
	my $self = shift;
	$self->stop_timer();
	$self->store();
}

sub _update {
	my ($data) = @_;
	my $c      = Kynetx::MongoDB::get_collection(COLLECTION);
	my $result = $c->insert($data);
	return $result;
}

sub add_tag {
	my $self   = shift;
	my $logger = get_logger();
	my $tag    = shift;
	if ( ref $tag eq "ARRAY" ) {
		$logger->trace( "Is array: ", sub { Dumper($tag) } );
		my @temp = ( @{ $self->{"tags"} }, @$tag );
		$self->{"tags"} = \@temp;
	}
	else {
		CORE::push( @{ $self->{"tags"} }, $tag );
	}
	return $self->{"tags"};
}

sub get_data {
	my ($key,$limits) = @_;
	my $logger   = get_logger();
	my $c        = Kynetx::MongoDB::get_collection(COLLECTION);
	my $cnt = 0;
	my $order = -1;
	my $limit = 15000;
	if (defined $limits) {	
		$order = $limits->{'sort_order'} || $order;
		$limit = $limits->{'limit'} || $limit;
	}	
	$logger->debug("Key: ", sub {Dumper($key)});
	my $cursor = $c->find($key)->sort({'$natural' => $order})->limit($limit);
	if ( $cursor->has_next ) {
		my @array_of_datapoints = ();
		while ( my $obj = $cursor->next ) {
			my $dp;
			foreach my $key (keys %{$obj}) {
				if ($key eq "metric") {
					foreach my $mkey (keys %{$obj->{$key}}) {
						$dp->{$mkey} = $obj->{$key}->{$mkey};
					}
				} elsif ($key eq "tags") {
					$dp->{$key} = join(",",@{$obj->{$key}})
				} elsif (ref $obj->{$key} eq "") {
					$dp->{$key} = $obj->{$key};
				} elsif ($key eq "_id") {
					$dp->{"id"} = $obj->{$key}->{'value'};
				}
			}
			$logger->trace("P: ", sub {Dumper($dp)});
			CORE::push(@array_of_datapoints,$dp);
		}
		return \@array_of_datapoints;
	} else {
		$logger->debug("No data");
		return undef;
	}
}

sub mem_stats {
  my $self = shift;
  my @fields = ('Cached','SwapCached','SwapFree','Committed_AS');
  my $logger=get_logger();
  $logger->trace("ADD DATAPOINT Memstats");
  my $mem_info = "/proc/meminfo";
  open(my $mem_stats,"<",$mem_info) || die "Can not open $mem_info";
  my $hash;
  while (my $stat = <$mem_stats>) {
    my ($key,$val) = split(/:/,$stat);
    $val =~ s/^\s+|\s+$//g;
    $hash->{$key} = $val;
  }
  $self->memfree($hash->{'MemFree'});
  for my $stat (@fields) {
    my $val = $hash->{$stat};
    $self->push($stat,$val);
    $logger->trace("K: $stat V: $val");
  }
  return $self->memfree();
}


1;
