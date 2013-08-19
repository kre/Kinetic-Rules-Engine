#!/usr/bin/perl -w 
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
use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::Deep;

use Kynetx::KTime;
use DateTime;
use POSIX qw(strftime);

use Data::Dumper;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

my $num_tests = 0;
my $t_only = '23:20:00';
my $set_time = strftime "%a %b %e $t_only %Y",localtime;
my $e_time = Kynetx::KTime->parse_datetime($set_time)->epoch();

my $test_dates =  {
  '19800507T0850'                   => 326537400,         #ISO8601
  'Sat, 19 Jul 2003 15:53:45 -0500' => 1058648025,        #HTTP
  'Wed, 22 Jan 2003 01:29:47 -0500 (EST)' => 1043216987,  #Mail
  $t_only => $e_time,                                     #ISO8601
  '1985102T1015Z' => 482148900,                           #ISO8601
  '1985-04-12T10:15:30+04' => 482134530,                  #ISO8601
  '1985-04-12T10:15:30.5+04:00' => 482134530,             #ISO8601
  '+001985-W15' => 481766400,                             #ISO8601
};


foreach my $tdate (keys %{$test_dates}) {
  my $description = $num_tests++. ": Test format: $tdate";  
  my $dt = Kynetx::KTime->parse_datetime($tdate);
  cmp_deeply($dt->epoch(),$test_dates->{$tdate},$description);
}

my @test_strptime = (
  [ '1998-12-31', '%Y-%m-%d',           915062400 ],
  [ '98-12-31',   '%y-%m-%d',           915062400 ],
  [ '1998 years, 312 days', '%Y years, %j days', 910483200 ],
  [ 'Jan 24, 2003', '%b %d, %Y',         1043366400 ],
  [ 'January 24, 2003', '%B %d, %Y',     1043366400 ],
  [ '1998-12-30', 
    {
      'pattern' => '%Y-%m-%d'
    },
    914976000 ],
  [ '2003 23:45:56 MDT', 
    {
      'pattern' => '%Y %H:%M:%S %Z',
      'time_zone' => 'Australia/Perth'
    },                   
    1041486356 ],
  [ '2003 23:45:56 +1000', 
    {
      'pattern' => '%Y %H:%M:%S %z',
      'time_zone' => 'Australia/Perth'
    },                   
    1041428756 ],
  [ '2003 23:45:56 +1000 AEST', 
    {
      'pattern' => '%Y %H:%M:%S %z %Z',
      'time_zone' => 'Australia/Perth'
    },                   
    1041428756 ],
  [ '2003 23:45:56 AEST', 
    {
      'pattern' => '%Y %H:%M:%S %Z',
      'time_zone' => 'Australia/Perth'
    },                   
    1041428756 ],
    [  'Tue Aug 13 21:16:45 +0000 2013',
      {
        'pattern' => '%a %b %d %H:%M:%S %z %Y'
      },
      1376428605
    ]
);

foreach (@test_strptime) {
  my ( $data, $pattern, $expect ) = @$_;
  my $description = $num_tests++. ": Test format: $data"; 
  my $dt = Kynetx::KTime->parse_datetime($data,$pattern);
  cmp_deeply($dt->epoch(),$expect,$description);
}


done_testing($num_tests);
1;


