package Kynetx::FakeReq;

use strict;
use warnings;

#
# This package simulates a mod_perl request object for testing
#

#constructor
sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

# fake methods for requests
sub subprocess_env {
    return 0;
}
# fake methods for requests
sub content_type {
    return 0;
}

1;
