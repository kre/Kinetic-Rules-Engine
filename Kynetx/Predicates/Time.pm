package Kynetx::Predicates::Time;
# file: Kynetx/Predicates/Time.pm
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

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Predicates::Weather qw(get_weather);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_local_time
local_time_between
local_day_of_week
today_is
)],
);

our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (
    # time predicates

    'timezone' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $tz = get_weather($req_info, 'timezone');

	return $tz eq $desired;
    },
   
    'daytime' => sub {
	my ($req_info, $rule_env, $args) = @_;
	my $logger = get_logger();

	my $sunrise = get_weather($req_info, 'sunrise');
	$sunrise =~ y/ /:/;
	my @sr = split(/:/, $sunrise);
	$sr[0] += 12 if $sr[2] eq 'pm';

        # assume it's daytime if we don't get good data
	return 1 unless defined $sr[0];  

	my $sunset = get_weather($req_info, 'sunset');
	$sunset =~ y/ /:/;
	my @ss = split(/:/, $sunset);
	$ss[0] += 12 if $ss[2] eq 'pm';

        # assume it's daytime if we don't get good data
	return 1 unless defined $ss[0];

	my $now = get_local_time($req_info);

	my $srto = $now->clone;
	$srto->set_hour($sr[0]);
	$srto->set_minute($sr[1]);


	my $ssto = $now->clone;
	$ssto->set_hour($ss[0]);
	$ssto->set_minute($ss[1]);
	

	# returns 1 if a > b
	my $after_sunrise = DateTime->compare($now,$srto);
	my $before_sunset = DateTime->compare($ssto,$now);

	$logger->debug( 
	    "Time for cust: " . $now->hms . " (" . $now->time_zone->name . ") " . 
	    "After Sunrise: " . $after_sunrise . " " .
	    "Before Sunset: " . $before_sunset . " " 
	    );
	

	return $after_sunrise eq 1 && $before_sunset eq 1;
   
    
    },

    # between 6:00 and 12:00
    'morning' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 6, 0, 12, 0)
    
    },

    # between 10:00 and 12:00
    'late_morning' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 10, 0, 12, 0)
    
    },

    # between 11:30 and 13:00
    'lunch_time' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 11, 30, 13, 0)
    
    },

    

    # between 12:00 and 17:00
    'afternoon' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 12, 0, 17, 0)
    
    },

    # between 12:00 and 15:00
    'early_afternoon' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 12, 0, 15, 0)
    
    },

    # between 15:00 and 17:00
    'late_afternoon' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 15, 0, 17, 0)
    
    },

    # between 17:00 and 20:00
    'evening' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 17, 0, 20, 0)
    
    },

    # between 20:00 and 24:00
    'night' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 20, 0, 23, 59)
    
    },

    # day of week
    'day_of_week' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_day_of_week($req_info) eq $args->[0];
    
    },

    'weekend' => sub {
	my ($req_info, $rule_env, $args) = @_;
	my @weekend = (1,0,0,0,0,0,1);
	return today_is($req_info, \@weekend);
    },

    'weekday' => sub {
	my ($req_info, $rule_env, $args) = @_;
	my @weekday = (0,1,1,1,1,1,0);
	return today_is($req_info, \@weekday);
    },

    'today_is' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return today_is($req_info, $args);
    },

    'time_between' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_time_between($req_info, 
				  $args->[0], 
				  $args->[1], 
				  $args->[2], 
				  $args->[3]);
    },

    'date_between' => sub {
	my ($req_info, $rule_env, $args) = @_;
	return local_date_between($req_info, 
				  $args->[0], # start month
				  $args->[1], # start day
				  $args->[2], # start year
				  $args->[3], # end month
				  $args->[4],  # end day
				  $args->[5] # end year
	    );
    },

    'date_start' => sub {
	my ($req_info, $rule_env, $args) = @_;

	return local_date_between(
	    $req_info, 
	    $args->[0], 
	    $args->[1], 
	    $args->[2], 
	    12, 31, 2020  # a long time in the future
	    );
    },


    );


# need predicates already defined for this
$predicates{'nighttime'} = sub {
    return ! $predicates{'daytime'}(@_)

};


sub get_predicates {
    return \%predicates;
}

# Gets a time object that reflects the current time for the user's locality
# this code has the potential of breaking badly when the server
# clock/timzone is not set right...
sub get_local_time {
    my($req_info) = @_;

    my $logger = get_logger();

    my $tz = get_weather($req_info, 'timezone');
    $logger->debug("Timezone ", $tz);

    # FIXME: need to do better with time zones
    $tz =~ s#E.T#America/New_York#;
    $tz =~ s#C.T#America/Chicago#;
    $tz =~ s#M.T#America/Denver#;
    $tz =~ s#P.T#America/Los_Angeles#;

    # FIXME: this code has the potential of breaking badly when the server
    # clock/timzone is not set right...
    my $now = DateTime->now;  
    $now->set_time_zone($tz) if defined $tz;

    return $now;

}

sub local_time_between {

	my ($req_info, $start_hour, $start_minute, $end_hour, $end_minute) = @_;
	my $logger = get_logger();

	return local_datetime_between(
	    $req_info, 
	    0, 0, 0, $start_hour, $start_minute, 0, 
	    0, 0, 0, $end_hour, $end_minute, 0);
				      
}

sub local_date_between {

	my ($req_info, $start_month, $start_day, $start_year, 
	               $end_month, $end_day, $end_year) = @_;
	my $logger = get_logger();

	return local_datetime_between(
	    $req_info, 
	    $start_year, $start_month, $start_day, 0, 0, 0,
	    $end_year, $end_month, $end_day, 0, 0, 0
	    );
				      
}


sub local_datetime_between {

	my ($req_info, $start_year, $start_month, $start_day, 
	               $start_hour, $start_minute, $start_second,
                       $end_year, $end_month, $end_day,
	               $end_hour, $end_minute, $end_second
	    ) = @_;
	my $logger = get_logger();

	my $now = get_local_time($req_info);

	# cloning keeps us from having to set lots of stuff
	my $start_time = $now->clone;
	$start_time->set(year => $start_year ||= $start_time->year, 
			 month => $start_month ||= $start_time->month, 
			 day => $start_day ||= $start_time->day,
			 hour => $start_hour ||= $start_time->hour, 
			 minute => defined($start_minute) ? 
			           $start_minute : $start_time->minute, 
			 second => defined($start_second) ?
			           $start_second : $start_time->second
	    );



	my $end_time = $now->clone;
	$end_time->set(year => $end_year ||= $end_time->year, 
		       month => $end_month ||= $end_time->month, 
		       day => $end_day ||= $end_time->day,
		       hour => $end_hour ||= $end_time->hour, 
		       minute => defined($end_minute) ? 
		                 $end_minute : $end_time->minute, 
		       second => defined($end_second) ?
		                 $end_second : $end_time->second

	    );


	# returns 1 if a > b
	my $after_start_time = DateTime->compare($now,$start_time);
	my $before_end_time = DateTime->compare($end_time,$now);

	$logger->debug( 
	    "Time for cust: " . $now->ymd . " " .$now->hms . 
	    " (" . $now->time_zone->name . ") " . 
	    "After start time: " . $start_time->ymd . " " . $start_time->hms . " " .
	    "Before end time: " . $end_time->ymd . " " . $end_time->hms . " " 
	    );
	


	return $after_start_time eq 1 && $before_end_time eq 1;

}



my @dow = qw(
Sunday
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
);

sub local_day_of_week {
    my ($req_info) = @_;
    my $logger = get_logger();

    my $now = get_local_time($req_info);

    my $dow = $dow[$now->day_of_week];
    $logger->debug("Day of week is ", $dow);

    return $dow;

}

sub today_is {
    # days is an array with elements 0 - 6 indicating days
    my ($req_info, $days) = @_;
    my $logger = get_logger();

    my $now = get_local_time($req_info);

    my $dow = ($now->day_of_week);

    $logger->debug("Today is ", $dow);
    
    return $days->[$dow];
    
}


1;
