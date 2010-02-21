#!/usr/bin/perl -w 

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

