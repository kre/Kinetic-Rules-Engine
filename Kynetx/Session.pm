package Kynetx::Session;
# file: Kynetx/Session.pm
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


# use kns_config qw(get_config);

use Log::Log4perl qw(get_logger :levels);
use IPC::Lock::Memcached;
use Digest::MD5;

use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use Kynetx::Configure qw(:all);
use Kynetx::Persistence::KEN qw(
    get_ken
);
use Kynetx::Persistence::Entity qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use constant MAX_STACK_SIZE => 50;


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
    my ($r, $ck, $tk) = @_;


    my $logger = get_logger();

    my $cookie;
    my $ubx_token;
    
    # check the cookie
    $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/^.*[;]?SESSION_ID=(\w*)[;]?.*$/$1/ if(defined $cookie);
    $cookie = $ck if $ck;  # override, used for testing and _sid param
    $logger->debug("Passed cookie: ", $cookie);
    
	# was an explicit token passed?
    if (defined $tk) {
      $logger->info("Explicit token: (SKY) $tk");
      if ($tk ne "") {
		my $token = Kynetx::Persistence::KToken::is_valid_token($tk);
		if ($token) {
			# Stored session is forfeit in sky instance
			$cookie = new_session_id();
			Kynetx::Persistence::KToken::set_token($token,$cookie);
			#my $session = { "_session_id" => $cookie};
			# but, don't set a new cookie session
			#return $session;			
		}
      } else {
		$logger->warn("Empty Explicit Token received");
      }
    }
    
    # Check to see if the UBX has sent us a token
    $ubx_token = $r->headers_in->{'Kobj-Session'};
    
    if (defined $ubx_token) {
      my $token;
      if ($token = Kynetx::Persistence::KToken::is_valid_token($ubx_token)) {
		$logger->info("Received valid token: $ubx_token");
		my $tcookie = $token->{"endpoint_id"};
		if ($tcookie ne $cookie) {
	  		my $old_cookie = $cookie;
	  		$cookie = new_session_id();
	  		$logger->debug("Old cookie was: $old_cookie");
	  		$logger->debug("New session is: $cookie");
	  		Kynetx::Persistence::KToken::set_token($ubx_token,$cookie);
	  		Kynetx::Persistence::KToken::delete_token(undef,$old_cookie,undef);    			    		
		} else {
	  		$logger->debug("Tokens are the same");
		}
      } else {
		$logger->debug("Invalid token: ", $ubx_token);
      }
    }


    
    


    if (defined $cookie) {
		$logger->info("Using session id: ", $cookie );
    } else {
		$cookie = new_session_id(); 	
		$logger->info("No session id found, created $cookie" );
    }
    
    my $session= { "_session_id" => $cookie};    

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

sub new_session_id {
	my $length = 32;
	my $tmp = substr(Digest::MD5::md5_hex(Digest::MD5::md5_hex(time(). {}. rand(). $$)), 0, $length);
	my $session= { "_session_id" => $tmp};
	my $token = Kynetx::Persistence::KToken::get_token($session,"","web");
	if ($token) {
		# Get another session ID because somehow this one has been used already
		return new_session_id();
	} else {
		return $tmp;
	}
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

    my $logger = get_logger();

    my $session_id = session_id($session);

    $logger->debug("Cleaning up session");
    untie %{ $session };

#    if ($req_info && $req_info->{"_lock"}) {
#      $logger->debug("Session lock cleared for $session_id");
#      $req_info->{"_lock"}->unlock;
#    }
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
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    my $status = Kynetx::Persistence::Entity::put_edatum($rid,$ken,$var,$val);

    if ($status) {
        return $val;
    } else {
        return undef;
    }


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
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);

    my $val = Kynetx::Persistence::Entity::get_edatum($rid,$ken,$var);
    if (defined $val) {
        return $val;
    } else {
        return undef;
    }
}

sub session_created {
    my ($rid, $session, $var) = @_;
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    return Kynetx::Persistence::Entity::get_created($rid,$ken,$var);
}


sub session_defined {
    my ($rid, $session, $var) = @_;
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);

    return defined get_edatum($rid,$ken,$var);
}

sub session_delete {
    my ($rid, $session, $var) = @_;
    my $logger = get_logger();
    $logger->debug("Delete session var: $var");
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    return delete_edatum($rid,$ken,$var);
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
    $logger->debug("Push on $var: ",sub {Dumper($val)});
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
	   session_store($rid,$session,$var,$s);
    }
    return $res->[0]; # just the value
}

# TODO: delete this sub since it is not used?...
sub session_next {
    my ($rid, $session, $var) = @_;
    my $logger = get_logger();

    my $res = undef;
    my $s = session_get($rid, $session, $var);
    $logger->debug("[Session next] session: ", sub {Dumper($s)});
    if(ref $s eq 'ARRAY') {
       $logger->debug("[Session_next] is Array");
	   $res = pop @{ $s };
	   session_store($rid,$session,$var,$s);
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
