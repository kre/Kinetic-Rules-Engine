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
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->easy_init($INFO);
use Kynetx::Configure;

use Kynetx::Test qw/:all/;
use Kynetx::Log qw/:all/;

Kynetx::Configure::configure();

my $num_tests = 0;

is(Kynetx::Log::array_to_string(["foo", "bar"]), "[foo,bar]", 
   "array to string with array");
$num_tests++;

is(Kynetx::Log::array_to_string([]), "[]", "array to string with undef");
$num_tests++;


is(Kynetx::Log::array_to_string(undef), "[]", "array to string with undef");
$num_tests++;


is(Kynetx::Log::array_to_string("foo"), "[]", "array to string with string");
$num_tests++;


is(Kynetx::Log::array_to_string(5), "[]", "array to string with number");
$num_tests++;


# logging is a big harder to test
my $logger=get_logger();

my $description = "Check that configure() set the proper log level";
my $llevel = $logger->level();
my $priority = Log::Log4perl::Level::to_level( $llevel );
my $env_level = Kynetx::Configure::get_log_threshold();
is($env_level,$priority,$description);
$num_tests++;
Log::Log4perl::MDC->put('site', 'smoke');
Log::Log4perl::MDC->put('rule', '[test]');  # no rule for now...

Kynetx::Util::turn_off_logging();
$logger->debug("debug");
$logger->info("info");
$logger->warn("warn");
$logger->error("error");
$logger->fatal("fatal");  

Kynetx::Util::turn_on_logging();
diag "Debug";
$logger->debug("debug");
diag "Info";
$logger->info("info");
diag "warn";
$logger->warn("warn");
diag "error";
$logger->error("error");
diag "fatal";
$logger->fatal("fatal"); 

$logger->log($TRACE, "...");
$logger->log($DEBUG, "debug...");
$logger->log($INFO, "info...");
$logger->log($WARN, "warn...");
$logger->log($ERROR, "error...");
$logger->log($FATAL, "fatal...");

$logger->debug("__SCREEN__");

done_testing($num_tests);
1;


