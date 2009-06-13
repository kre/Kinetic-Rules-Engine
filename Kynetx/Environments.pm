package Kynetx::Environments;
# file: Kynetx/Environments.pm

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

    if(! defined $env || ! (ref $env eq 'HASH')) {
	return undef;
    } elsif ($env->{$key}) {
	return $env->{$key};
    } else {
	return lookup_rule_env($key, $env->{'___sub'});
    }
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
