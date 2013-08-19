package Kynetx::KTime;

# file: Kynetx/Sets.pm
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

use DateTime;
use DateTime::Format::HTTP;
use DateTime::Format::Mail;
use DateTime::Format::ISO8601;
use DateTime::Format::RFC3339;
use DateTime::Format::Strptime;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
  all => [
    qw(
      )
  ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use DateTime::Format::Builder (
  parsers => {
    parse_datetime => [
    #[preprocess => \&alogger],
      sub {eval {DateTime::Format::ISO8601->parse_datetime( $_[1])}},
      sub {eval {DateTime::Format::HTTP->parse_datetime( $_[1])}},
      sub {eval {DateTime::Format::Mail->parse_datetime( $_[1])}},
      sub {eval {DateTime::Format::ISO8601->parse_time( $_[1])}},
      sub {
        my $logger = get_logger();
        my $obj = $_[1];
        my $pattern = $_[3];
        $logger->trace("Obj: $obj");
        $logger->trace("Pat: $pattern");
        return undef if $pattern eq '';
        my $strp = DateTime::Format::Strptime->new(pattern => '%T');
        if (ref $pattern eq '') {
          $strp->pattern($pattern);
        } elsif (ref $pattern eq 'HASH') {
          $strp->pattern($pattern->{'pattern'}) if (defined $pattern->{'pattern'});
          $strp->locale($pattern->{'locale'}) if (defined $pattern->{'locale'});
          $strp->time_zone($pattern->{'time_zone'}) if (defined $pattern->{'time_zone'});
        }
        #$logger->debug("DT str: ", sub {Dumper($strp)});
        return $strp->parse_datetime($obj);
      },
      
    ]
  }
);

sub alogger {
  my %args = @_;
  my ($date, $p) = @args{qw( input parsed )};
  my $logger = get_logger();
  $logger->debug("KTime",sub {Dumper(%args)});
  return $date;
}

1;
