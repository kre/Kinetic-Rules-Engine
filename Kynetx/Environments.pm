package Kynetx::Environments;
# file: Kynetx/Environments.pm
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

#    my $logger = get_logger();
#    $logger->debug('$env has type ', ref $env);
#    $logger->debug("Looking for $key");

    if(! defined $env || ! (ref $env eq 'HASH')) {
	return undef;
    } elsif (defined $env->{$key}) {
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

#    my $logger = get_logger();
#    $logger->debug('$keys has type ', ref $keys);

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
