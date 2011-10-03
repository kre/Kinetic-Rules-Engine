package Kynetx::Environments;
# file: Kynetx/Environments.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
empty_rule_env
lookup_rule_env
extend_rule_env
add_to_env
flatten_env
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub empty_rule_env {
    return {};
}

sub lookup_rule_env {
    my($key,$env) = @_;

    my $logger = get_logger();
    $logger->trace("Looking for $key");

    if(! defined $env || ! (ref $env eq 'HASH')) {
	return undef;
    } elsif (defined $env->{$key}) {
    	$logger->trace("Found: $key with (", $env->{$key}, ")");
		return $env->{$key};
    } else {
	return lookup_rule_env($key, $env->{'___sub'});
    }
}

# add key-value pairs to current env, overwriting any that are already there
sub add_to_env {
  my($hash, $env) = @_;

  foreach my $k (keys %{$hash}) {
    push(@{$env->{'___vars'}}, $k) unless defined $env->{$k};
    $env->{$k} = $hash->{$k};
  }
  return $env;
}

# Takes three or two arguments. 
# If three, an array of keys, and array of vals, and an env to extend
# If two, a hash to use in enxtending env in the second
sub extend_rule_env {

    if(@_ == 3) {

	my($keys, $vals, $env) = @_;
	my $new_env = {'___sub' =>$env};

    my $logger = get_logger();

	if(ref $keys eq 'ARRAY' && ref $vals eq 'ARRAY') {
	    $new_env->{'___vars'} = $keys;
	    my $i = 0;
	    foreach my $key (@{ $keys}) {
		$new_env->{$key} = $vals->[$i++];
	    }
	} elsif(ref $keys eq 'SCALAR' || ref $keys eq '') {
	    $new_env->{'___vars'} = [$keys];
	    $new_env->{$keys} = $vals;
	}

	return $new_env;

    } elsif(@_ == 2) {
	my($hash, $env) = @_;
	my $new_env = {'___sub' =>$env};

#    my $logger = get_logger();
#    $logger->debug('$keys has type ', ref $keys);

	if(ref $hash eq 'HASH') {
	    my @keys = keys %{ $hash };

	    $new_env->{'___vars'} = \@keys;
	    my $i = 0;
	    foreach my $key (@keys) {
		$new_env->{$key} = $hash->{$key};
	    }
	} 
	
	return $new_env;
    }


}

sub event_rule_env {
	my ($event) = @_;
	my $logger = get_logger();
	my $kvHash;
	my $req_info = $event->get_req_info();
	my $env = empty_rule_env();
	
	# Set the tag for explicit events
	my $type = $event->get_type();
	my ($domain,$eventid) = split(/:/,$type);
	$kvHash->{$eventid} = 1;
	$kvHash->{'url'} = $req_info->{'caller'};
	return add_to_env($kvHash,$env);
	#return $env;
}

# returns a hash with the variables and values proper reflecting scoping
sub flatten_env {
    my ($env) = @_;
    return flatten_env_aux($env, {});
}

sub flatten_env_aux {
    my ($env, $result) = @_;
    if(! defined $env || ! (ref $env eq 'HASH')) {
	return $result;
    } else {
	my @this_scope_order;
	foreach my $k (@{$env->{'___vars'}}) {
	    push(@this_scope_order, $k) unless grep $k eq $_, @{ $result->{'___order'}};
	    $result->{$k} = $env->{$k} unless ($k eq '___sub') || (defined $result->{$k});
	}
	unshift(@{$result->{'___order'}},@this_scope_order);
	$result = flatten_env_aux($env->{'___sub'}, $result);
    }
}


1;
