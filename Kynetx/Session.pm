package Kynetx::Session;
# file: Kynetx/Session.pm
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


# use kns_config qw(get_config);

use Log::Log4perl qw(get_logger :levels);
use IPC::Lock::Memcached;

use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use Kynetx::Configure qw(:all);
use Kynetx::Persistence::KEN qw(
    get_ken
);
use Kynetx::Memcached;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use constant MAX_STACK_SIZE => 50;
use constant EXPIRE => 60;

use constant DEFAULT_MEMCACHED_PORT => '11211';


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
process_session
session_cleanup
session_id
session_keys
session_store
session_touch
session_get
session_created
session_delete
session_defined
session_within
session_inc_by_from
session_set
session_clear
session_true
session_push
session_pop
session_next
session_history
session_forget
session_seen
session_seen_within
session_seen_compare
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub process_session {
    my ($r, $ck) = @_;
    my $logger = get_logger();
    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/^.*[;]?SESSION_ID=(\w*)[;]?.*$/$1/ if(defined $cookie);

    $cookie = $ck if $ck;  # mainly for testing

    if (defined $cookie) {
	$logger->debug("Using session id: ", $cookie );
    } else {
	$logger->debug("No session id found" );
    }

    my $session;

    eval {
	$session = tie_servers($session,$cookie);
    };

    # catch an error ($cookie not found is the most usual)
    if ($@) {
        $logger->debug("tie error: ",sub {Dumper($@)});
	undef $cookie; # creates a new session
	$logger->debug("Create cookie...");
	$session = tie_servers($session,$cookie);
    }

    # we don't need the value at the moment, but we need to
    # force the creation of an anonymous KEN if none is found
    get_ken($session);

    my $dt = DateTime->now;


    # create expires timestamp
    $dt = $dt->add(days => 364);
    my $expires = $dt->strftime("%a, %d-%b-%Y 23:59:59 GMT");


    # might be a new session, so lets give them their cookie back
    #  with an updated expiration
    my $session_cookie =
	"SESSION_ID=$session->{_session_id};path=/;domain=" .
	Kynetx::Configure::get_config('COOKIE_DOMAIN') .
	';expires=' . $expires; #Mon, 31-Dec-2012 00:00:00 GMT';
    $logger->debug("Sending cookie: ", $session_cookie);
    $r->headers_out->add('Set-Cookie' => $session_cookie);

    return $session;

}



sub tie_servers {

    my($session,$cookie) = @_;

    # presumes memcached has already been initialized
#    my $mem_servers = Kynetx::Memcached::get_memcached_servers();
    my $mem_servers = Kynetx::Configure::get_config('SESSION_SERVERS');

    my $logger = get_logger();
    $logger->trace("Using ", $mem_servers, " for session storage");
    $logger->trace("Session: ",sub { Dumper($session)});
    $logger->trace("Cookie: ", sub {Dumper($cookie)});
    $logger->trace("session servers: ", sub {Dumper($mem_servers)});


    tie %{$session}, 'Apache::Session::Memcached', $cookie, {
	Servers => $mem_servers,
	NoRehash => 1,
	Readonly => 0,
	Debug => 0,
	CompressThreshold => 10_000
    };

    return $session;

}

sub session_cleanup {
    my($session,$req_info) = @_;
    if ($req_info && $req_info->{"_lock"}) {
        $req_info->{"_lock"}->unlock;
    }

    untie %{ $session };
}

sub session_id {
    my ($session) = @_;
    return $session->{_session_id};
}

sub session_keys {
    my ($rid, $session) = @_;
    my @keys = keys %{ $session->{$rid} };
    return \@keys;
}

sub session_store {
    my ($rid, $session, $var, $val) = @_;
    my $logger = get_logger();
    $logger->trace("session store: ",$var," = ",$val);

    # timestamp session to ensure it gets written back
    my $dt = DateTime->now->epoch;
    $session->{'_timestamp'} = $dt;

    $session->{$rid} = {} unless exists $session->{$rid};

    $session->{$rid}->{$var} = $val;
    $session->{$rid}->{$var.'_created'} = $dt;
    return $val;

}

sub session_touch {
    my ($rid, $session, $var, $dt) = @_;

    $session->{$rid}->{$var} = 0 unless exists $session->{$rid}->{$var};

    if(defined $dt) {
	$session->{$rid}->{$var.'_created'} = $dt->epoch;
    } else {
	$session->{$rid}->{$var.'_created'} = DateTime->now->epoch;
    }

    return $session->{$rid}->{$var};

}

sub session_get {
    my ($rid, $session, $var) = @_;
    my $val;
    if(exists $session->{$rid} && exists $session->{$rid}->{$var}) {
	   $val =  $session->{$rid}->{$var};
    } else {
	   $val =  undef;
    }
    return $val;
}

sub session_created {
    my ($rid, $session, $var) = @_;
    my $val;

    if(exists $session->{$rid} && exists $session->{$rid}->{$var}) {
	$val =  $session->{$rid}->{$var.'_created'};
    } else {
	$val =  undef;
    }
    return $val;
}


sub session_defined {
    my ($rid, $session, $var) = @_;

    return exists $session->{$rid} && exists $session->{$rid}->{$var};
}

sub session_delete {
    my ($rid, $session, $var) = @_;
    # timestamp session to ensure it gets written back
    my $dt = DateTime->now->epoch;
    $session->{'_timestamp'} = $dt;

    if(exists $session->{$rid} && exists $session->{$rid}->{$var}) {
	delete $session->{$rid}->{$var};
	delete $session->{$rid}->{$var.'_created'};
    }
}


sub session_within {
    my ($rid, $session, $var, $timevalue, $timeframe) = @_;
    my $logger = get_logger();

    my $desired = DateTime->from_epoch(
	epoch => session_created($rid, $session, $var)
	);

#    $logger->debug("[session:$var] created ", $desired->datetime());

#    $logger->debug("Timeframe: $timeframe, Timevalue: $timevalue");

    $desired->add( $timeframe => $timevalue );

    $logger->debug("[session:$var] ",
		   $timeframe, " -> ", $timevalue,
		   ' desired ', $desired->datetime()
	);

    return Kynetx::Util::after_now($desired);
}

sub session_inc_by_from {
    my ($rid, $session, $var, $val, $from) = @_;
    my $logger = get_logger();
    if(session_defined($rid, $session, $var)) {
	my $old = session_get($rid, $session, $var);
	session_store($rid, $session, $var, $old + $val);
	$logger->debug("iterating session var ",
		       $var,
		       " from ",
		       $old,
		       " by ",
		       $val);

    } else {
	session_store($rid, $session, $var, $from);
	$logger->debug("initializing session var ",
		       $var,
		       " to ",
		       $from);
    }
    return session_get($rid, $session, $var);
}


sub session_set {
    my ($rid, $session, $var) = @_;
    return session_store($rid, $session, $var, 1);
}

sub session_clear {
    my ($rid, $session, $var) = @_;
    session_delete($rid, $session, $var);
    return undef;
}

sub session_true {
    my ($rid, $session, $var) = @_;
    return session_get($rid, $session, $var);
}

# stack stuff
#
# we want to know the creation time of each member of the stack so...
#  - we store each value as a tuple [value, created]
#
sub session_push {
    my ($rid, $session, $var, $val) = @_;
    my $logger = get_logger();

    my $res = [];
    my $tuple = [$val, DateTime->now->epoch];
    if (session_defined($rid, $session, $var)) {

	my $s = session_get($rid, $session, $var);
	if(ref $s eq 'ARRAY') {
	    unshift @{ $s }, $tuple;
	    # store the array after slicing it to the right length
	    if(scalar @{$s} >= MAX_STACK_SIZE) {
		delete $s->[MAX_STACK_SIZE]
	    }
	    $res = session_store($rid, $session, $var, $s);
	    $logger->debug("Pushing $val onto $var");
	} else {
	    # not sure what to do but make a stack of it.
	    $res = session_store($rid, $session, $var,
				 [$tuple,
				  [$s, session_created($rid, $session, $var)]
				 ]);
	    $logger->debug("Pushing $val onto $var with previous");

	}

    } else {

	$res = session_store($rid, $session, $var, [$tuple]);
	$logger->debug("Pushing $val onto $var as new trail");

    }

    return $res;
}

sub session_pop {
    my ($rid, $session, $var) = @_;

    my $res = undef;
    my $s = session_get($rid, $session, $var);
    if(ref $s eq 'ARRAY') {
	$res = shift @{ $s };
    }
    return $res->[0]; # just the value
}

sub session_next {
    my ($rid, $session, $var) = @_;

    my $res = undef;
    my $s = session_get($rid, $session, $var);
    if(ref $s eq 'ARRAY') {
	$res = pop @{ $s };
    }
    return $res->[0]; # just the value
}

sub session_history {
    my ($rid, $session, $var, $index) = @_;

    my $res = undef;
    my $s = session_get($rid, $session, $var);
    if(ref $s eq 'ARRAY') {
	$res = $s->[$index];
    }
    return $res->[0];
}


sub session_seen_proto {
    my ($rid, $session, $var, $regexp) = @_;
#    my $logger = get_logger();

    my $res = undef;
    my $s = session_get($rid, $session, $var);

    for my $i (0..@{$s}-1){
	if($s->[$i]->[0] =~ /$regexp/) {
	    $res = $i;
	    last;
	}
    }
#    $logger->debug("Found ". $s->[$res]->[0]) if defined $res;
    # return index and date created
    if(defined $res) {
	return [$res, $s->[$res]->[1]];
    } else {
	return undef;
    }
}

sub session_seen {
    my ($rid, $session, $var, $regexp) = @_;

    my $seen = session_seen_proto($rid, $session, $var, $regexp);
    return $seen->[0];
}

sub session_seen_within {
    my ($rid, $session, $var, $regexp, $timevalue, $timeframe) = @_;
    my $logger = get_logger();

    my $seen = session_seen_proto($rid, $session, $var, $regexp);

    # the regexp isn't even there...let alone within a timeframe
    return 0 unless (defined $seen->[0]);

    my $desired = DateTime->from_epoch(
	epoch => $seen->[1]
	);

    $logger->debug("[session:$var] created ", $desired->datetime());

    $logger->debug("Timeframe: $timeframe, Timevalue: $timevalue");

    $desired->add( $timeframe => $timevalue );

    $logger->debug("[session:$var] ",
		   $timeframe, " -> ", $timevalue,
		   ' desired ', $desired->datetime()
	);

    return Kynetx::Util::after_now($desired);
}

# compares to see if 1 was added before 2
sub session_seen_compare {
    my ($rid, $session, $var, $regexp1, $regexp2) = @_;
    my $seen1 = session_seen_proto($rid, $session, $var, $regexp1);
    my $seen2 = session_seen_proto($rid, $session, $var, $regexp2);

    return $seen1->[0] < $seen2->[0]
}

sub session_forget {
    my ($rid, $session, $var, $regexp) = @_;
    my $s = session_get($rid, $session, $var);
    my $seen = session_seen_proto($rid, $session, $var, $regexp);
    splice(@{$s}, $seen->[0], 1) if defined $seen->[0];
    return session_store($rid, $session, $var, $s);
}



1;
