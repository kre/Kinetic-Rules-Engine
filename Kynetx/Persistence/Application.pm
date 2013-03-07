package Kynetx::Persistence::Application;
# file: Kynetx/Persistence/Application.pm
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
    get
    put
    get_created
    delete
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant COLLECTION => "appdata";

sub touch {
    my ($rid,$var,$ts) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    return Kynetx::MongoDB::touch_value(COLLECTION,$key,$ts)->{"value"};
}

sub get {
    my ($rid,$var,$get_ts) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = Kynetx::MongoDB::get_value(COLLECTION,$key);
    $logger->trace("GET ($var) using (",sub {Dumper($key)},") returns: ", sub {Dumper($value)});
    if ($get_ts) {
        return $value->{"created"};
    } else {
        return $value->{"value"};
    }

}

sub get_hash_app_element {
    my ($rid,$var,$hvar,$get_ts) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = Kynetx::MongoDB::get_hash_element(COLLECTION,$key,$hvar);
    $logger->trace("GET ($var) using (",sub {Dumper($key)},") returns: ", sub {Dumper($value)});
    if (defined $value && $get_ts) {
        return $value->{"created"};
    } else {
        return $value->{"value"};
    }
	
}

sub delete_hash_app_element {
    my ($rid,$var,$hvar) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    Kynetx::MongoDB::delete_hash_element(COLLECTION,$key,$hvar);	
}

sub put_hash_app_element {
	my ($rid,$var,$hvar,$val) = @_;
	my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
	my $key = {
        "rid" => $rid,
        "key" => $var
	};
	my $value = {
		'value' => $val
	};
	my $success = Kynetx::MongoDB::put_hash_element(COLLECTION,$key,$hvar,$value);
	return $success;	
}

sub pop {
    my ($rid,$var,$direction) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $result = Kynetx::MongoDB::pop_value(COLLECTION,$key,$direction);
    if ($result) {
        return $result;
    } else {
        return undef;
    }
}

sub push {
    my ($rid,$var,$val,$as_trail) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = {
        "rid"  => $rid,
        "key"  => $var,
        "value"=> $val,
    };
    my $success = Kynetx::MongoDB::push_value(COLLECTION,$key,$value,$as_trail);
    return $success;
}

sub get_created {
    my ($rid,$var) = @_;
    $rid = Kynetx::Rids::get_rid($rid);
    return get($rid,$var,1);
}




sub put {
    my ($rid,$var,$val,$expires) = @_;
    my $logger = get_logger();
    $rid = Kynetx::Rids::get_rid($rid);
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = clone ($key);
    $value->{'value'} = $val,
    $logger->trace("Store to $var: ",sub{Dumper($value)});
    my $success = Kynetx::MongoDB::update_value(COLLECTION,$key,$value,1);
    $logger->debug("Failed to upsert ", sub {Dumper($key)}) unless ($success);
    return $success;
}

sub delete {
    my ($rid,$var) = @_;
    $rid = Kynetx::Rids::get_rid($rid);
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $success = Kynetx::MongoDB::delete_value(COLLECTION,$key);
    return $success;

}


1;