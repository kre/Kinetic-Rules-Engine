package Kynetx::Predicates::Time;

# file: Kynetx/Predicates/Time.pm
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

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use DateTime::Format::ISO8601;

# why wasn't this required earlier
use DateTime::Format::RFC3339;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          get_local_time
          local_time_between
          local_day_of_week
          today_is
          )
    ],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
my $funcs      = {};
my %predicates = (

    # time predicates

    'timezone' => sub {
        my ( $req_info, $rule_env, $args ) = @_;

        my $desired = $args->[0];
        $desired =~ s/^'(.*)'$/$1/;    # for now, we have to remove quotes

        my $tz = get_timezone( $req_info);

        return $tz eq $desired;
    },

    # between 6:00 and 12:00
    'morning' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 6, 0, 12, 0 )

    },

    # between 10:00 and 12:00
    'late_morning' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 10, 0, 12, 0 )

    },

    # between 11:30 and 13:00
    'lunch_time' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 11, 30, 13, 0 )

    },

    # between 12:00 and 17:00
    'afternoon' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 12, 0, 17, 0 )

    },

    # between 12:00 and 15:00
    'early_afternoon' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 12, 0, 15, 0 )

    },

    # between 15:00 and 17:00
    'late_afternoon' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 15, 0, 17, 0 )

    },

    # between 17:00 and 20:00
    'evening' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 17, 0, 20, 0 )

    },

    # between 20:00 and 24:00
    'night' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_time_between( $req_info, 20, 0, 23, 59 )

    },

    # day of week
    'day_of_week' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_day_of_week($req_info) eq $args->[0];

    },

    'weekend' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my @weekend = ( 1, 0, 0, 0, 0, 0, 1 );
        return today_is( $req_info, \@weekend );
    },

    'weekday' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my @weekday = ( 0, 1, 1, 1, 1, 1, 0 );
        return today_is( $req_info, \@weekday );
    },

    'today_is' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return today_is( $req_info, $args );
    },

    'time_between' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return
          local_time_between( $req_info,  $args->[0], $args->[1],
                              $args->[2], $args->[3] );
    },

    'date_between' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return local_date_between(
                                   $req_info,
                                   $args->[0],    # start month
                                   $args->[1],    # start day
                                   $args->[2],    # start year
                                   $args->[3],    # end month
                                   $args->[4],    # end day
                                   $args->[5]     # end year
        );
    },

    'date_start' => sub {
        my ( $req_info, $rule_env, $args ) = @_;

        return local_date_between(
            $req_info,
            $args->[0],
            $args->[1],
            $args->[2],
            12, 31, 2020    # a long time in the future
        );
    },

);

sub get_predicates {
    return \%predicates;
}

sub now {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->trace( "Function: $function with ", sub { Dumper($args) } );
    my $now = get_local_time($req_info);
    $logger->trace( $now->strftime("%x %X") );
    if ( defined $args ) {
        if ( $args->[0] ) {
            my $p = $args->[0];
            my $tz = $p->{'timezone'} || $p->{'tz'} || get_timezone($req_info);
            if ($tz) {
                $now->set_time_zone($tz);
            }
        }
    }
    my $f = DateTime::Format::RFC3339->new();
    return $f->format_datetime($now);
}
$funcs->{'now'} = \&now;

sub new {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->trace( "Function: $function with ", sub { Dumper($args) } );
    my $utime = $args->[0];
    if ( !defined $utime ) {
        return now();
    } else {
        my $f = DateTime::Format::RFC3339->new();
        return $f->format_datetime(ISO8601($utime));
    }
    return undef;
}
$funcs->{'new'} = \&new;

sub add {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->trace( "Function: $function with ", sub { Dumper($args) } );
    if ( ref $args->[0] eq '' ) {
        my $utime = $args->[0];
        my $dt = ISO8601($utime);
        if (defined $dt) {
	    my $tz = $dt->time_zone();
            $dt->set_time_zone('UTC');
            if ( ref $args->[1] eq 'HASH' ) {
                $dt->add( $args->[1] );
                if (defined $tz) {
                	$dt->set_time_zone($tz);
                }                
                my $f = DateTime::Format::RFC3339->new();
                return $f->format_datetime($dt);
            } else {
                $logger->debug( "Found: ", ref $args->[1], " Requires: {<timeunit> : <number>}" );
                my $f = DateTime::Format::RFC3339->new();
                return $f->format_datetime($dt);
            }

        }

    }

}
$funcs->{'add'} = \&add;

sub strformat {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->trace( "Function: $function with ", sub { Dumper($args) } );
    if ( ref $args->[0] eq '' ) {
        my $utime = $args->[0];
        my $dt = ISO8601($utime);
        $logger->trace("iso8601 date: ", sub {Dumper($dt)});
        if (defined $dt) {
            if (defined $args->[2]) {
                my $p = $args->[2];
                my $tz = $p->{'timezone'} || $p->{'tz'} || get_timezone($req_info);
                if ($tz) {
                    $dt->set_time_zone($tz);
                }
            }
            return $dt->strftime($args->[1]);
        }
    }

}
$funcs->{'strftime'} = \&strformat;

sub httpformat {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->trace( "Function: $function with ", sub { Dumper($args) } );
    if ( ref $args->[0] eq '' ) {
        my $utime = $args->[0];
        my $dt = ISO8601($utime);
        $dt->set_time_zone('UTC');
        $logger->trace("iso8601 date: ", sub {Dumper($dt)});
        return $dt->strftime('%a, %d %b %Y %H:%M:%S GMT');
    }

}
$funcs->{'httptime'} = \&httpformat;

sub compare {
	my ( $req_info, $function, $args ) = @_;
	my $logger = get_logger();
	my $t1 = $args->[0];
	my $t2 = $args->[1];
	my $error = undef;
	if (defined $t1 and defined $t2) {
		my $dt1 = eval {ISO8601($t1)};
		my $dt2 = eval {ISO8601($t2)};
		if ($@) {
			$error .= 'time module, conversion error: ' . $@;
		}
		if (defined $dt1 and defined $dt2) {
			$dt1->set_time_zone('UTC');
			$dt2->set_time_zone('UTC');
			return DateTime->compare($dt1,$dt2);
		} else {
			$error .= "Invalid time comparison: (". $dt1 . "/" . $dt2 . ")";
		}
	} else {
		$error .= 'function time:compare requires two arguments';
	}
	if (defined $error) {
		Kynetx::Errors::raise_error($req_info,
			'warn',
			$error,
			{
				'genus' => 'system',
				'species' => 'time module'
			}
			);		
	}
	return undef;
}
$funcs->{'compare'} = \&compare;

sub atom {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    my $atom_strftime = "%FT%TZ";
    $logger->trace( "Function: $function with ", sub { Dumper($args) } );    
    if ( ref $args->[0] eq '' ) {
        my $utime = $args->[0];
        my $dt = ISO8601($utime);
        $dt->set_time_zone('UTC');
        if (defined $dt) {
        	my $f = DateTime::Format::RFC3339->new();
        	$dt->set_formatter($f);
            if (defined $args->[1] ) {
                my $p = $args->[1];
                my $tz = $p->{'timezone'} || $p->{'tz'} || get_timezone($req_info);
                if ($tz) {
                    $dt->set_time_zone($tz);
                } 
            }
            return $dt->strftime($atom_strftime);
        }
    }

}
$funcs->{'atom'} = \&atom;

sub ISO8601 {
    my ($utime) = @_;
    my $logger = get_logger();
    my $dt;
    eval { $dt = DateTime::Format::ISO8601->parse_datetime($utime) };
    if ($@) {
    	eval {$dt = DateTime::Format::ISO8601->parse_time($utime)};
        if ($@) {
        	$logger->warn( "String format error: ", $@ );
        	$logger->debug("Format: $dt");
        } else {
        	return $dt;
        }
    } else {
    	#my $tz = $dt->time_zone();
        return $dt;
    }
    return undef;
}

sub get_time {
    my ( $req_info, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->debug( "Time evaluation with function -> ", $function );
    my $f = $funcs->{$function};
    if ( defined $f ) {
        return $f->( $req_info, $function, $args );
    } else {
        $logger->debug("Function ($function) undefined");
    }
}

# Gets a time object that reflects the current time for the user's locality
# this code has the potential of breaking badly when the server
# clock/timzone is not set right...
sub get_local_time {
    my ($req_info) = @_;

    my $logger = get_logger();

    my $tz = get_timezone($req_info);

    $logger->debug( "Timezone ", $tz );

    my $now = DateTime->now;
    if (defined $tz) {
      eval {
        $now->set_time_zone($tz)
      };
      if ($@) {
        $logger->warn("Error: set time zone $tz: $@")
      }
    }
    return $now;
}

sub get_timezone {
  my($req_info) = @_;
  my $tz = Kynetx::Request::get_attr($req_info,"_timezone") || "UTC";
  return $tz;
}


sub local_time_between {

    my ( $req_info, $start_hour, $start_minute, $end_hour, $end_minute ) = @_;
    my $logger = get_logger();

    return
      local_datetime_between( $req_info, 0, 0, 0, $start_hour, $start_minute, 0,
                              0, 0, 0, $end_hour, $end_minute, 0 );

}

sub local_date_between {

    my (
         $req_info,  $start_month, $start_day, $start_year,
         $end_month, $end_day,     $end_year
    ) = @_;
    my $logger = get_logger();

    return
      local_datetime_between(
                              $req_info,    $start_year,
                              $start_month, $start_day,
                              0,            0,
                              0,            $end_year,
                              $end_month,   $end_day,
                              0,            0,
                              0
      );

}

sub local_datetime_between {

    my (
         $req_info,   $start_year,   $start_month,  $start_day,
         $start_hour, $start_minute, $start_second, $end_year,
         $end_month,  $end_day,      $end_hour,     $end_minute,
         $end_second
    ) = @_;
    my $logger = get_logger();

    my $now = get_local_time($req_info);

    # cloning keeps us from having to set lots of stuff
    my $start_time = $now->clone;
    $start_time->set(
         year  => $start_year  ||= $start_time->year,
         month => $start_month ||= $start_time->month,
         day   => $start_day   ||= $start_time->day,
         hour  => $start_hour  ||= $start_time->hour,
         minute => defined($start_minute) ? $start_minute : $start_time->minute,
         second => defined($start_second) ? $start_second : $start_time->second
    );

    my $end_time = $now->clone;
    $end_time->set(
        year  => $end_year  ||= $end_time->year,
        month => $end_month ||= $end_time->month,
        day   => $end_day   ||= $end_time->day,
        hour  => $end_hour ||=
          $end_time->hour,
        minute => defined($end_minute) ? $end_minute : $end_time->minute,
        second => defined($end_second)
        ? $end_second
        : $end_time->second

    );

    # returns 1 if a > b
    my $after_start_time = DateTime->compare( $now,      $start_time );
    my $before_end_time  = DateTime->compare( $end_time, $now );

    $logger->debug(   "Time for cust: "
                    . $now->ymd . " "
                    . $now->hms . " ("
                    . $now->time_zone->name . ") "
                    . "After start time: "
                    . $start_time->ymd . " "
                    . $start_time->hms . " "
                    . "Before end time: "
                    . $end_time->ymd . " "
                    . $end_time->hms
                    . " " );

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

    my $dow = $dow[ $now->day_of_week ];
    $logger->debug( "Day of week is ", $dow );

    return $dow;

}

sub today_is {

    # days is an array with elements 0 - 6 indicating days
    my ( $req_info, $days ) = @_;
    my $logger = get_logger();

    my $now = get_local_time($req_info);

    my $dow = ( $now->day_of_week );

    $logger->debug( "Today is ", $dow );

    return $days->[$dow];

}



1;
