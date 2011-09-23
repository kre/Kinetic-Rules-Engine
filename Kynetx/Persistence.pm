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
        defined_persistent_var
        delete_trail_element
        add_trail_element
        contains_trail_element
        trail_element_before
        trail_element_within
        trail_element_index
        consume_trail_element
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
    $logger->trace("Delete $domain","var: $varname");
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        Kynetx::Persistence::Entity::delete_edatum($rid,$ken,$varname);
    } elsif ($domain eq 'app') {
        Kynetx::Persistence::Application::delete($rid,$varname);
    }
}

sub delete_persistent_hash_element {
    my ($domain,$rid,$session,$varname,$path) = @_;
    my $logger = get_logger();
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        Kynetx::Persistence::Entity::delete_hash_edatum($rid,$ken,$varname,$path);
    } elsif ($domain eq 'app') {
        Kynetx::Persistence::Application::delete_hash_app_element($rid,$varname,$path);
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
    $logger->trace("Save $domain","var: $varname$op_name");
    my $status;
    if ($domain eq 'ent') {
        $logger->trace("Session after before KEN query: ", sub {Dumper($session)});
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $logger->trace("Session after new KEN query: ", sub {Dumper($session)});
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

sub save_persistent_hash_element {
	my ($domain,$rid,$session,$varname,$path,$value) = @_;
	my $logger = get_logger();
	my $status;
	if ($domain eq 'ent') {
		my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
		$status = Kynetx::Persistence::Entity::put_hash_edatum($rid,$ken,$varname,$path,$value);
	} else {
		$status = Kynetx::Persistence::Application::put_hash_app_element($rid,$varname,$path,$value);
	}
}


# see MongoDB $inc
sub increment_persistent_var {
    my ($domain,$rid,$session,$varname,$value,$from) = @_;
    my $logger = get_logger();
    my $old_value = get_persistent_var($domain,$rid,$session,$varname);
    if (defined $old_value) {
        save_persistent_var($domain,$rid,$session,$varname,$old_value + $value);
        $logger->trace("var $varname in(de)cremented by $value");
    } else {
        save_persistent_var($domain,$rid,$session,$varname,$from);
        $logger->trace("var $varname initialized to $from");
    }
    return get_persistent_var($domain,$rid,$session,$varname);
}

sub get_persistent_var {
    my ($domain,$rid,$session,$varname,$gcreated) = @_;
    my $logger = get_logger();
    $logger->trace("Get $domain","var: $varname");
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

# See if I can avoid writing a timestamp request
#   my ($domain,$rid,$session,$varname,$path,$ts) = @_;
sub get_persistent_hash_element {
	my ($domain,$rid,$session,$varname,$path) = @_;
	my $logger = get_logger();
	my $val;
	if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $val = Kynetx::Persistence::Entity::get_hash_edatum($rid,$ken,$varname,$path);
    } elsif ($domain eq 'app') {
        $val = Kynetx::Persistence::Application::get_hash_app_element($rid,$varname,$path);
    }
    return $val;
	
}

sub defined_persistent_var {
    my ($domain,$rid,$session,$varname) = @_;
    my $logger = get_logger();
    $logger->trace("Exists $domain","var: $varname");
    return defined get_persistent_var($domain,$rid,$session,$varname);

}

sub persistent_var_within {
    my ($domain,$rid,$session,$varname,$timevalue,$timeframe)= @_;
    my $logger = get_logger();
    $logger->trace("Check $varname within ", sub {Dumper($timevalue)}, ",",sub {Dumper($timeframe)});
    my $created = get_persistent_var($domain,$rid,$session,$varname,1);
    return 0 unless (defined $created);
    my $desired = DateTime->from_epoch(epoch => $created);
    $desired->add($timeframe => $timevalue);
    return Kynetx::Util::after_now($desired);
}


sub touch_persistent_var {
    my ($domain,$rid,$session,$varname,$timestamp) = @_;
    my $logger = get_logger();
    $logger->trace("Touch $domain","var: $varname (",$timestamp || "",")");
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
sub delete_trail_element {
    my ($domain, $rid, $session, $varname, $regexp) = @_;
    my $logger = get_logger();
    $logger->trace("Forget /$regexp/ from $varname");
    my $trail = get_persistent_var($domain,$rid,$session,$varname);
    if (ref $trail eq "ARRAY") {
        my $found = 0;
        my @narry;;
        foreach my $element (@{$trail}) {
            if ($element->[0] =~ /$regexp/ && !$found) {
                $found = 1;
                $logger->trace("skip element: ",$element->[0]);
            } else {
                $logger->trace("save element: ",$element->[0]);
                push(@narry,$element);
            }
        }
        return save_persistent_var($domain,$rid,$session,$varname,\@narry);
    } else {
        $logger->warn("Persistent variable is not a valid trail");
    }
}

# MongoDB has an atomic $push operation that could simplify this method
sub add_trail_element {
    my ($domain, $rid, $session, $varname, $value) = @_;
    my $logger = get_logger();
    $logger->trace("Push $domain","var onto $varname");
    my $tuple = [$value,DateTime->now->epoch];
    my $status;
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $status = Kynetx::Persistence::Entity::push_edatum($rid,$ken,$varname,$tuple,1);
    } elsif ($domain eq 'app') {
        $status = Kynetx::Persistence::Application::push($rid,$varname,$tuple,1);

    }

}

sub consume_trail_element {
    my ($domain, $rid, $session, $varname, $direction) = @_;
    my $logger = get_logger();
    my $op_name = $direction ?  "Shift" : "Pop";
    $logger->trace("$op_name from $varname");
    my $result;
    if ($domain eq 'ent') {
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        $result = Kynetx::Persistence::Entity::pop_edatum($rid,$ken,$varname,$direction);
        $logger->trace("$op_name returned: ", sub {Dumper($result)});
    } elsif ($domain eq 'app') {
        $result = Kynetx::Persistence::Application::pop($rid,$varname,$direction);
    }
    if ($result) {
        return $result->[0];
    } else {
        return undef;
    }

}

sub trail_element_index {
    my ($domain,$rid,$session,$varname,$regexp)= @_;
    my $logger = get_logger();
    $logger->trace("Index $varname for ",sub {Dumper($regexp)});
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

sub persistent_element_history {
    my ($domain,$rid,$session,$varname,$index)= @_;
    my $logger = get_logger();
    my $result = undef;
    $logger->trace("Check $varname for $index element");
    my $trail = get_persistent_var($domain,$rid,$session,$varname);
    # Mongo does not support queue operations
    # convert $index to Stack notation
    if (ref $trail eq 'ARRAY') {
    	my $size = @$trail;
        $result =  $trail->[$size - $index -1]->[0];
    	$logger->trace("Looks like ($size)",sub {Dumper($trail)});
    }
    return $result;
}

sub contains_trail_element {
    my ($domain,$rid,$session,$varname,$regexp)= @_;
    my $logger = get_logger();
    $logger->trace("Check $varname for ",sub {Dumper($regexp)});
    my $res = trail_element_index($domain,$rid,$session,$varname,$regexp);
    if (defined $res) {
        return $res->[0];
    } else {
        return undef;
    }
}

sub trail_element_before {
    my ($domain,$rid,$session,$varname,$regexp1,$regexp2)= @_;
    my $logger = get_logger();
    $logger->trace("Check $varname for ",sub {Dumper($regexp1)}, " before ", sub {Dumper($regexp2)});
    my $first = trail_element_index($domain,$rid,$session,$varname,$regexp1);
    my $second = trail_element_index($domain,$rid,$session,$varname,$regexp2);
    return $first->[0] < $second->[0];
}

sub trail_element_within {
    my ($domain,$rid,$session,$varname,$regexp,$timevalue,$timeframe)= @_;
    my $logger = get_logger();
    $logger->trace("Check $varname for ",sub {Dumper($regexp)}, " within ", sub {Dumper($timevalue)}, ",",sub {Dumper($timeframe)});
    my $element_index = trail_element_index($domain,$rid,$session,$varname,$regexp);
    return undef unless (defined $element_index);
    my $desired = DateTime->from_epoch(epoch => $element_index->[1]);
    $desired->add($timeframe => $timevalue);
    return Kynetx::Util::after_now($desired);
}

1;
