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
plan tests => 5;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Log qw/:all/;


is(Kynetx::Log::array_to_string(["foo", "bar"]), "[foo,bar]", 
   "array to string with array");

is(Kynetx::Log::array_to_string([]), "[]", "array to string with undef");

is(Kynetx::Log::array_to_string(undef), "[]", "array to string with undef");

is(Kynetx::Log::array_to_string("foo"), "[]", "array to string with string");

is(Kynetx::Log::array_to_string(5), "[]", "array to string with number");

1;


