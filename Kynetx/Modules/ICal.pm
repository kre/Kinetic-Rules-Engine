package Kynetx::Modules::ICal;
# file: Kynetx/Modules/ICal.pm
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

use Log::Log4perl qw(get_logger :levels);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use DateTime;
use Data::ICal::Entry::Event;
use Data::ICal::DateTime; 
use DateTime::Format::ISO8601 ;
use Data::UUID;

use Data::Dumper;


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my $predicates = {};

sub get_predicates {
  return $predicates;
}

#my $actions = { send => { directive => \&send_event }, };

my $actions = {};
sub get_actions {
  return $actions;
}

my $funcs = {};

sub get_eventinfo {
}


sub generate_ical_from_array {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();

    my $entries = $args->[0];
    my $meta = $args->[1];

    if (! ref $entries eq 'array') {
	$logger->debug("Arg one to iCal_from_array should be array; saw ", ref $entries)
    }

    my $calendar = Data::ICal->new();
    $calendar->add_properties( 
		     'X-WR-CALNAME' => $meta->{"name"} || "Calendar",
	             'X-WR-CALDESC' => $meta->{"desc"} || ""
    );

    
    my $ug = new Data::UUID;

    foreach my $entry (@{ $entries }) {
	my $vevent = Data::ICal::Entry::Event->new();

	my $start = DateTime::Format::ISO8601->parse_datetime($entry->{"dtstart"});
	my $end = DateTime::Format::ISO8601->parse_datetime($entry->{"dtend"}) if defined $entry->{"dtend"};

	$vevent->start($start);
	$vevent->end($end);

	if (defined $entry->{"geo"}) {
	    $entry->{"geo"} =~ s/,/;/;
#	    $logger->debug("Geo data ", $entry->{"geo"});
	}

	# dealt with these above
	delete $entry->{"dtstart"};
	delete $entry->{"dtend"};

#	$logger->debug("Entry data: ", sub {Dumper $entry});
	$vevent->add_properties( %{ $entry } );

	
	$vevent->add_property(uid => $ug->to_string($ug->create())) unless $entry->{"uid"};

	$calendar->add_entry($vevent);
    }

    my $cal = $calendar->as_string;
    # I don't know why it does this and it's broken, so we'll hack it
    $cal =~ s/\\,/,/g;
    return $cal;

}
$funcs->{'from_array'} = \&generate_ical_from_array;


sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();
    $logger->trace("Function:", sub {Dumper($function)});
    my $resp = undef;
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info, $function, $args );
    	};
    	if ($@) {
    		$logger->warn("ICal error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module ICal");
    }

    return $resp;
}



1;
