package Kynetx::Persistence;

# file: Kynetx/Persistence.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
        delete_persistent_var
        save_persistent_var
        increment_persistent_var
        get_persistent_var
        touch_persistent_var
        delete_persistent_element
        add_persistent_element
        contains_persistent_element
        persistent_element_before
        persistent_element_within
        persistent_element_index
        consume_persistent_element
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use Kynetx::Persistence::KEN qw(
    get_ken
);
use Kynetx::Persistence::Entity;# qw(:all);
use Kynetx::Persistence::Application;# qw(:all);


use Data::Dumper;
$Data::Dumper::Indent = 1;


sub delete_persistent_var {
    my ($domain,$rid,$session,$varname) = @_;
    my $logger = get_logger();
    $logger->debug("Delete $domain","var: $varname");
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        Kynetx::Persistence::Entity::delete_edatum($rid,$ken,$varname);
    } elsif ($domain eq 'app') {
        Kynetx::Persistence::Application::delete($rid,$varname);
    }
}

sub save_persistent_var {
    my ($domain,$rid,$session,$varname,$value) = @_;
    my $op_name = "";
    if (! $value) {
        $value = 1;
        $op_name = " as flag"
    }

    my $logger = get_logger();
    $logger->debug("Save $domain","var: $varname$op_name");
    my $status;
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $status = Kynetx::Persistence::Entity::put_edatum($rid,$ken,$varname,$value);
    } elsif ($domain eq 'app') {
        $status = Kynetx::Persistence::Application::put($rid,$varname,$value);

    }
    if ($status) {
        return $value;
    } else {
        return undef;
    }
}


# see MongoDB $inc
sub increment_persistent_var {
    my ($domain,$rid,$session,$varname,$value,$from) = @_;
    my $logger = get_logger();
    my $old_value = get_persistent_var($domain,$rid,$session,$varname);
    if (defined $old_value) {
        save_persistent_var($domain,$rid,$session,$varname,$old_value + $value);
        $logger->debug("var $varname in(de)cremented by $value");
    } else {
        save_persistent_var($domain,$rid,$session,$varname,$from);
        $logger->debug("var $varname initialized to $from");
    }
    return get_persistent_var($domain,$rid,$session,$varname);
}

sub get_persistent_var {
    my ($domain,$rid,$session,$varname,$gcreated) = @_;
    my $logger = get_logger();
    $logger->debug("Get $domain","var: $varname");
    my $val = undef;
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $val = Kynetx::Persistence::Entity::get_edatum($rid,$ken,$varname,$gcreated);
    } elsif ($domain eq 'app') {
        $val = Kynetx::Persistence::Application::get($rid,$varname,$gcreated);
    }

    if (defined $val) {
        return $val;
    } else {
        return undef;
    }

}

sub touch_persistent_var {
    my ($domain,$rid,$session,$varname,$timestamp) = @_;
    my $logger = get_logger();
    $logger->debug("Touch $domain","var: $varname ($timestamp)");
    my $val = undef;
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $val = Kynetx::Persistence::Entity::touch_edatum($rid,$ken,$varname,$timestamp);
    } elsif ($domain eq 'app') {
        $val = Kynetx::Persistence::Application::touch($rid,$varname,$timestamp);
    }

    if (defined $val) {
        return $val;
    } else {
        return undef;
    }

}

# Trails
# see MongoDB $pop
sub delete_persistent_element {
    my ($domain, $rid, $session, $varname, $regexp) = @_;
    my $logger = get_logger();
    $logger->debug("Forget /$regexp/ from $varname");
    my $trail = get_persistent_var($domain,$rid,$session,$varname);
    if (ref $trail eq "ARRAY") {
        my $found = 0;
        my @narry;;
        foreach my $element (@{$trail}) {
            if ($element->[0] =~ /$regexp/ && !$found) {
                $found = 1;
                $logger->debug("skip element: ",$element->[0]);
            } else {
                $logger->debug("save element: ",$element->[0]);
                push(@narry,$element);
            }
        }
        return save_persistent_var($domain,$rid,$session,$varname,\@narry);
    } else {
        $logger->warn("Persistent variable is not a valid trail");
    }
}

# MongoDB has an atomic $push operation that could simplify this method
sub add_persistent_element {
    my ($domain, $rid, $session, $varname, $value) = @_;
    my $logger = get_logger();
    $logger->debug("Push $domain","var onto $varname");
    my $trail = get_persistent_var($domain,$rid,$session,$varname);

    my $tuple = [$value, DateTime->now->epoch];
    if ($trail) {
        if (ref $trail eq 'ARRAY') {
            unshift @{$trail},$tuple;
            $logger->debug("Pushing $domain","var onto $varname");
        } else {
            $logger->debug("$varname is not a valid trail, but it is going to be...");
            # param of 1 returns var creation time instead of value
            my $timestamp = get_persistent_var($domain,$rid,$session,$varname,1);
            $trail = [$tuple,[$trail,$timestamp]];
        }
    } else {
        $trail = [$tuple];
        $logger->debug("Pushing $domain","var onto $varname as new trail");
    }
    return save_persistent_var($domain,$rid,$session,$varname,$trail);
}

sub consume_persistent_element {
    my ($domain, $rid, $session, $varname, $direction) = @_;
    my $logger = get_logger();
    my $op_name = $direction ? "Pop" : "Shift";
    $logger->debug("$op_name from $varname");
    my $trail = get_persistent_var($domain,$rid,$session,$varname);
    if (ref $trail eq "ARRAY") {
        my $res;
        if ($direction) {
            # pop
            $res = pop @{$trail};
        } else {
            # shift
            $res = shift @{$trail};
        }
        save_persistent_var($domain,$rid,$session,$varname,$trail);
        return $res->[0];
    } elsif (ref $trail eq "") {
        # Single value, return and delete
        delete_persistent_var($domain,$rid,$session,$varname);
        return $trail;
    }
    $logger->warn("Invalid trail request, found (",ref $trail,") as $varname");
}

sub persistent_element_index {
    my ($domain,$rid,$session,$varname,$regexp)= @_;
    my $logger = get_logger();
    $logger->debug("Index $varname for ",sub {Dumper($regexp)});
    my $trail = get_persistent_var($domain,$rid,$session,$varname);
    my $index = undef;
    for my $i (0..@{$trail}-1) {
        if ($trail->[$i]->[0] =~ /$regexp/) {
            $index = $i;
            last;
        }
    }
    if (defined $index) {
        return [$index,$trail->[$index]->[1]];
    } else {
        return undef;
    }
}

sub contains_persistent_element {
    my ($domain,$rid,$session,$varname,$regexp)= @_;
    my $logger = get_logger();
    $logger->debug("Check $varname for ",sub {Dumper($regexp)});
    my $res = persistent_element_index($domain,$rid,$session,$varname,$regexp);
    if (defined $res) {
        return $res->[0];
    } else {
        return undef;
    }
}

sub persistent_element_before {
    my ($domain,$rid,$session,$varname,$regexp1,$regexp2)= @_;
    my $logger = get_logger();
    $logger->debug("Check $varname for ",sub {Dumper($regexp1)}, " before ", sub {Dumper($regexp2)});
    my $first = persistent_element_index($domain,$rid,$session,$varname,$regexp1);
    my $second = persistent_element_index($domain,$rid,$session,$varname,$regexp2);
    return $first->[1] < $second->[1];
}

sub persistent_element_within {
    my ($domain,$rid,$session,$varname,$regexp,$timevalue,$timeframe)= @_;
    my $logger = get_logger();
    $logger->debug("Check $varname for ",sub {Dumper($regexp)}, " within ", sub {Dumper($timevalue)}, ",",sub {Dumper($timeframe)});
    my $element_index = persistent_element_index($domain,$rid,$session,$varname,$regexp);
    return 0 unless ($element_index);
    my $desired = DateTime->from_epoch(epoch => $element_index->[1]);
    $desired->add($timeframe => $timevalue);
    return Kynetx::Util::after_now($desired);
}

1;
