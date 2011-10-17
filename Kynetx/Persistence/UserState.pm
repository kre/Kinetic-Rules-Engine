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
use warnings;
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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant COLLECTION => "edata";
use constant EVCOLLECTION => "events";
use constant EEKEY => "__event_env__";


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
    my $value = Kynetx::MongoDB::get_value(COLLECTION,$key);
    return $value->{"value"};
}

sub set_current_state {
    my ($rid,$session,$rulename,$val) = @_;
    my $logger = get_logger();
    my $state_key = $rulename . ':sm_current';
    $logger->debug("Set SM current: ", $state_key);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    my $key = {
        "ken" => $ken,
        "rid" => $rid,
        "key" => $state_key};
    
    my $value = clone $key;
    $value->{"value"} = $val;
	my $success = Kynetx::MongoDB::update_value(COLLECTION,$key,$value,1,0,1);
    $logger->debug("Failed to upsert ", sub {Dumper($key)}) unless ($success);
    return $success;
	
}

sub delete_current_state {
    my ($rid,$session,$rulename) = @_;
    my $logger = get_logger();
    my $state_key = $rulename . ':sm_current';
    $logger->debug("Del SM current: ", $state_key);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $key = {
        "ken" => $ken,
        "rid" => $rid,
        "key" => $state_key};
    Kynetx::MongoDB::delete_value(COLLECTION,$key);
    reset_event_env($rid,$session,$rulename);	
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
    $logger->debug("Get event env: ", $rid);
    my $value = Kynetx::MongoDB::get_value(EVCOLLECTION,$key);
	return $value;	
}

sub reset_event_env {
	my ($rid,$session,$rulename) = @_;
    my $logger = get_logger();
    $logger->debug("Reset event env: ", $rid);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
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

sub reset_group_counter {
	my ($rid,$session,$rulename,$state) = @_;
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $query = {
		"rid" => $rid,
		"ken" => $ken,
		"rulename" => $rulename
	};
	my $update = {
		'$set' => {"$state" => 0}
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

1;