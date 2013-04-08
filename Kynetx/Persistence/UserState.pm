package Kynetx::Persistence::UserState;
# file: Kynetx/Persistence/Entity.pm
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
use lib qw(
    /web/lib/perl
);


use Log::Log4perl qw(get_logger :levels);
use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Session qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use MongoDB;
use MongoDB::OID;
use Clone qw(clone);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	get_current_state
	set_current_state
	delete_current_state
	inc_group_counter
	reset_group_counter
	get_timer_start
	repeat_group_counter
	push_aggregator
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant COLLECTION => "edata";
use constant EVCOLLECTION => "events";
use constant EEKEY => "__event_env__";
use constant STATE_COLLECTION => "userstate";


sub get_current_state {
    my ($rid,$session,$rulename) = @_;
    my $logger = get_logger();
    my $state_key = $rulename . ':sm_current';
    $logger->debug("Get SM current: ", $state_key);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $key = {
        "ken" => $ken,
        "rid" => $rid,
        "key" => $state_key};
    #my $value = Kynetx::MongoDB::get_value(COLLECTION,$key);
    my $value;
    $value = Kynetx::MongoDB::get_singleton(STATE_COLLECTION,$key);
	if (defined $value) {
		$logger->trace("$state_key found in ",STATE_COLLECTION,sub {Dumper($value)});
	} else {
		$logger->debug("$state_key not found in ",STATE_COLLECTION);
		$value = Kynetx::MongoDB::get_singleton(COLLECTION,$key);
		if (defined $value) {
			$logger->debug("Found $state_key in ", COLLECTION);
			$logger->debug("Copy state to ",STATE_COLLECTION);
			set_current_state($rid,$session,$rulename,$value);
			purge_state_from_edata($rid,$session,$rulename);
		}
	};
    
    return $value->{"value"};
}

sub set_current_state {
    my ($rid,$session,$rulename,$val) = @_;
    my $logger = get_logger();
    my $state_key = $rulename . ':sm_current';
    $logger->trace("Set SM current: ", $state_key);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    my $key = {
        "ken" => $ken,
        "rid" => $rid,
        "key" => $state_key};
    
    my $value = clone $key;
    $value->{"value"} = $val;
	my $success = Kynetx::MongoDB::update_value(STATE_COLLECTION,$key,$value,1,0,1);
    $logger->debug("Failed to upsert ", sub {Dumper($key)}) unless ($success);
    return $success;
	
}

sub delete_current_state {
    my ($rid,$session,$rulename) = @_;
    my $logger = get_logger();
    my $state_key = $rulename . ':sm_current';
    $logger->trace("Del SM current: ", $state_key);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $key = {
        "ken" => $ken,
        "rid" => $rid,
        "key" => $state_key};
    Kynetx::MongoDB::delete_value(STATE_COLLECTION,$key);
    reset_event_env($rid,$session,$rulename, $ken);	
}

sub purge_state_from_edata {
    my ($rid,$session,$rulename) = @_;
    my $logger = get_logger();
    my $state_key = $rulename . ':sm_current';
    $logger->trace("Del SM current: ", $state_key);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $key = {
        "ken" => $ken,
        "rid" => $rid,
        "key" => $state_key};
    Kynetx::MongoDB::delete_value(COLLECTION,$key);	
}

sub get_event_env {
	my ($rid,$session,$rulename) = @_;
    my $logger = get_logger();
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $key = {		
        "rid" => $rid,
        "ken" => $ken,
		"rulename" => $rulename
	};
    $logger->trace("Get event env: ", $rid);
    #my $value = Kynetx::MongoDB::get_value(EVCOLLECTION,$key);
    my $value = Kynetx::MongoDB::get_singleton(EVCOLLECTION,$key);
	return $value;	
}

sub reset_event_env {
	my ($rid,$session,$rulename, $ken) = @_;

    $ken ||= Kynetx::Persistence::KEN::get_ken($session,$rid);
    
    my $logger = get_logger();
    $logger->trace("Reset event env: ", $rid);
    my $key = {
        "rid" => $rid,
        "ken" => $ken,
		"rulename" => $rulename
    };    
	my $success = Kynetx::MongoDB::delete_value(EVCOLLECTION,$key);
    return $success;	
}

sub inc_group_counter {
	my ($rid,$session,$rulename,$state) = @_;
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"rulename" => $rulename
	};
	my $update = {
		'$inc' => {"$state" => 1}
	};
	my $new = 'true';
	my $upsert = 'true';
	my $fields = {"$state" => 1, '_id' => 0};
	my $fnmod = {
		'query' => $query,
		'update' => $update,
		'new' => $new,
		'upsert' => $upsert,
		'fields' => $fields
	};
	my $val = Kynetx::MongoDB::find_and_modify(EVCOLLECTION,$fnmod);
	return $val;
}

sub push_aggregator {
	my ($rid,$session,$rulename,$state,$vals) = @_;
	my $logger = get_logger();
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"rulename" => $rulename
	};
	my @val = ();
	if (ref $vals eq "ARRAY") {
		@val = @{$vals};
	} else {
		$logger->debug("Vals is: ", sub {Dumper($vals)});
		push(@val, $vals);
	}
	my $a_object =  {
		"timestamp"    => DateTime->now->epoch(),
		'val' => @val
	};
	my $update = {
		'$push' => {"$state" => $a_object}
	};
	my $new = 'true';
	my $upsert = 'true';
	my $fields = {"$state" => 1, '_id' => 0};
	my $fnmod = {
		'query' => $query,
		'update' => $update,
		'new' => $new,
		'upsert' => $upsert,
		'fields' => $fields
	};
	my $val = Kynetx::MongoDB::find_and_modify(EVCOLLECTION,$fnmod);
	return $val;
	
}

sub reset_group_counter {
	my ($rid,$session,$rulename,$state) = @_;
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"rulename" => $rulename
	};
	my $update = {
		'$set' => {"$state" => []}
	};
	my $new = 'true';
	my $upsert = 'true';
	my $fields = {"$state" => 1, '_id' => 0};
	my $fnmod = {
		'query' => $query,
		'update' => $update,
		'new' => $new,
		'upsert' => $upsert,
		'fields' => $fields
	};
	my $val = Kynetx::MongoDB::find_and_modify(EVCOLLECTION,$fnmod);
	return $val;
}

sub repeat_group_counter {
	my ($rid,$session,$rulename,$state,$current,$null_state) = @_;
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"rulename" => $rulename
	};
	my $update = {
		'$pop' => {"$state" => -1},
		'$set' => {"__repeat__.$current" => "$null_state"}
	};
	my $new = 'true';
	my $upsert = 'true';
	my $fields = {"$state" => 1, '_id' => 0};
	my $fnmod = {
		'query' => $query,
		'update' => $update,
		'new' => $new,
		'upsert' => $upsert,
		'fields' => $fields
	};
	my $val = Kynetx::MongoDB::find_and_modify(EVCOLLECTION,$fnmod);
	return $val;	
}

sub get_timer_start {
	my ($rid,$session,$rulename,$start) = @_;
	my $logger = get_logger();
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"rulename" => $rulename
	};
	#$logger->debug("Mongo query is: ", sub{Dumper($query)}); 	
    my $value = Kynetx::MongoDB::get_value(EVCOLLECTION,$query);
	return $value->{$start};	
}

sub next_event_from_list {
  my ($rid,$session,$event_list_name) = @_;
    my $logger = get_logger();
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"key" => $event_list_name		
	};
	my $result = Kynetx::MongoDB::atomic_pop_value(STATE_COLLECTION,$query);
	if (defined $result) {
		$logger->trace("$event_list_name found in ",STATE_COLLECTION, sub {Dumper($result)});
		return $result;
	} else {
	  $logger->debug("Event list not found");
	  return undef;
	}
#	} else {
#		my $val = Kynetx::MongoDB::get_value(COLLECTION,$query);
#		if (defined $val) {
#			my $object = $val->{'value'};
#			$logger->trace("$event_list_name found in ",COLLECTION,sub {Dumper($object)});
#			if (ref $object eq "ARRAY") {
#				$result = shift @{$object};
#				#put what is left of the event list into STATE_COLLECTION
#				Kynetx::MongoDB::atomic_push_value(STATE_COLLECTION,$query,$object);
#				Kynetx::MongoDB::delete_value(COLLECTION,$query);
#			} else {
#				$result = $object;
#			}
#			return $result;
#		} else {
#			$logger->debug("Event list not found");
#			return undef;
#		}
#		
#	}
#	return $result;

}

sub add_event_to_list {
	my ($rid, $session,	$event_list_name, $json) = @_;
    my $logger = get_logger();
    $logger->debug("In add_event_to_list");
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"key" => $event_list_name		    	
    };
    $logger->trace("Add event to $event_list_name: ", sub {Dumper($query)});
    $logger->trace("$event_list_name is: $json");
    my $status = Kynetx::MongoDB::atomic_push_value(STATE_COLLECTION,$query,$json);
#    my $temp = Kynetx::MongoDB::get_value(STATE_COLLECTION,$query);
#    $logger->debug("Add event to list returned: ", sub {Dumper($status)});
#    $logger->trace("State Collection query: ", sub {Dumper($temp)});
}


1;
