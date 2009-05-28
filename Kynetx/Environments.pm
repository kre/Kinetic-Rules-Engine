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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub empty_rule_env {
    return {};
}

sub lookup_rule_env {
    my($key,$env) = @_;
    if(! $env) {
	return undef;
    } elsif ($env->{$key}) {
	return $env->{$key};
    } else {
	return lookup_rule_env($key, $env->{'___sub'});
    }
}

sub extend_rule_env {
    my($keys, $vals, $env) = @_;

#    my $logger = get_logger();
#    $logger->debug('$keys has type ', ref $keys);

    my $new_env = {'___sub' =>$env};
    if(ref $keys eq 'ARRAY' && ref $vals eq 'ARRAY') {
	my $i = 0;
	foreach my $key (@{ $keys}) {
	    $new_env->{$key} = $vals->[$i++];
	}
    } elsif(ref $keys eq 'SCALAR' || ref $keys eq '') {
	$new_env->{$keys} = $vals;
    }

    return $new_env;
}


1;
