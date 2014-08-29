package Kynetx::Modules::CSV;
# file: Kynetx/Modules/CSV.pm
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
use DateTime::Format::ISO8601 ;
use Data::UUID;
use Text::CSV;

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

my $actions = { send => { directive => \&send_event }, };

sub get_actions {
  return $actions;
}

my $funcs = {};

sub get_eventinfo {
}


sub generate_csv_from_array {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();

    my $entries = $args->[0];

    if (! ref $entries eq 'array') {
	$logger->debug("Arg one to csv_from_array should be array; saw ", ref $entries)
    }

    my $csv = Text::CSV->new ();

    # create first line
    my $first = $entries->[0];
    #$logger->debug("Seeing ", defined $csv, sub{ Dumper keys %{$first} });

    my @first_line = keys %{$first};
    
    my $first_status = $csv->combine(keys %{$first}); # use keys as column names
    my $result;
    push @{$result}, $csv->string();
    

    foreach my $entry (@{ $entries }) {

	#$logger->debug("Seeing ", sub{ Dumper $entry});
	my $status = $csv->combine(values %{$entry});
	push @{$result}, $csv->string();
    }

    my $csv_string = join("\n", @{$result});
#    $logger->debug($csv_string);
    return $csv_string;

}
$funcs->{'from_array'} = \&generate_csv_from_array;


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
    		$logger->warn("CSV error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module CSV");
    }

    return $resp;
}



1;
