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
use lib qw(../);
use strict;

use Test::More;
use Test::LongString max => 300;
use Test::Deep;
use Data::Dumper;
use Net::hostent;

use APR::URI;
use APR::Pool ();

# most Kynetx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Configure qw/:all/;


plan tests => 3;

my @RUN_MODES = ( "development", "qa", "production" );

sub prune_hash {
	my ($hash,$trim) = @_;
	foreach my $key ( keys %$hash ) {
		if ( !defined $hash->{$key} ) {
			$hash->{$key} = ignore();
		}
		elsif ( ref $hash->{$key} eq 'HASH' and $trim ) {
			$hash->{$key} = ignore();
		}
		elsif ( $key eq 'SESSION_SERVERS' or $key eq 'MEMCACHE_SERVERS' ) {
			$hash->{$key} = ignore();
		}
	}
}

# New reference uses the default YML file from Configure.pm
Kynetx::Configure::configure();

# Run mode determines what the next level of verification on config
# variables beyond existance
# Valid options are (production|development)
my $runmode = Kynetx::Configure::get_config('RUN_MODE');

BAIL_OUT('Config variable RUN_MODE must be defined in the kns_config')
  unless ($runmode);

my $found = grep ( /^$runmode$/, @RUN_MODES );

BAIL_OUT("Run mode configuration variable ($runmode) is undefined")
  unless ($found);

# get a copy of the Kynetx::Configure::$config object
my $got = Kynetx::Configure::get_properties();

# Make sure that we aren't just returning false positives
ok( !exists $got->{'mustfail'}, 'Fake config variables fail' );

# Check to see that all of the values that are required are part of the active file
# You can only have one instance of Kynetx::Configure so reload with new file
my $template_file = "./data/base.yml";
Kynetx::Configure::configure($template_file);

# make things match
Kynetx::Configure::set_run_mode($runmode);

my $expected = Kynetx::Configure::get_properties();
prune_hash($expected,1);

cmp_deeply( $got, superhashof($expected), "Config Property Definitions" );

# Check the active file against our templates
$template_file = "./data/$runmode.yml";

Kynetx::Configure::configure($template_file);

$expected = Kynetx::Configure::get_properties();
prune_hash($expected);

#diag Dumper $got;
#diag Dumper $expected;

#cmp_deeply( $got, superhashof($expected), "Config Value Comparisons" );

# We can't guarantee what the name of the runtime is, but do some basic checking
my $re_runtime = qr|^http://static.kobj.net/(kobj-static-(\d+).js)$|;
$got->{'RUNTIME_LIB_NAME'} =~ $re_runtime;
diag "Using runtime: " . $1;
cmp_deeply($got->{'RUNTIME_LIB_NAME'},re($re_runtime),"Runtime file check");

1;

