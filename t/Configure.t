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
use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString max =>300;
use Data::Dumper;
use Net::hostent;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::JavaScript qw/:all/;

my @RUN_MODES = ("development","production");

plan tests => 40;


# Old reference to a test configure file
#Kynetx::Configure::configure("./data/kns_config.yml");


# New reference uses the default YML file from Configure.pm
Kynetx::Configure::configure(); 

# Run mode determines what the next level of verification on config
# variables beyond existance
# Valid options are (production|development)
my $runmode = Kynetx::Configure::get_config('RUN_MODE');

BAIL_OUT('Config variable RUN_MODE must be defined in the kns_config') 
    unless ($runmode);

my $found = grep (/^$runmode$/,@RUN_MODES);

BAIL_OUT("Run mode configuration variable ($runmode) is undefined") unless ($found);

# get a copy of the Kynetx::Configure::$config object 
my $active = Kynetx::Configure::get_properties();



# Make sure that we aren't just returning false positives
ok( !exists $active->{'mustfail'}, 'Fake config variables fail');

# Run Mode
ok( exists $active->{'RUN_MODE'}, 'Run mode exists');

# MEMCACHE
ok( exists $active->{'memcache'}, 'MEMCACHED Block exists');
ok( exists $active->{'memcache'}{'mcd_hosts'}, 'MEMCACHED Host Block exists');
ok( exists $active->{'memcache'}{'mcd_port'}, 'MEMCACHED Port exists');

# Sessions
ok( exists $active->{'sessions'}, 'Sessions Block exists');
ok( exists $active->{'sessions'}{'session_hosts'}, 'Session Host Block exists');
ok( exists $active->{'sessions'}{'session_port'}, 'Session Port exists');

# Cookie Domain
ok( exists $active->{'COOKIE_DOMAIN'}, 'Cookie Domain exists');

# Home directory
ok( exists $active->{'WEB_ROOT'}, 'Web root exists');

# KOBJ root
ok( exists $active->{'KOBJ_ROOT'}, 'KOBJ root exists');

# Admin address
ok( exists $active->{'SERVER_ADMIN'}, 'Admin address exists');

# Hostnames
ok( exists $active->{'INIT_HOST'}, 'Init hostname exists');
ok( exists $active->{'CB_HOST'}, 'CB hostname exists');
ok( exists $active->{'EVAL_HOST'}, 'Eval hostname exists');
ok( exists $active->{'KRL_HOST'}, 'KRL hostname exists');

# Rule Repository
ok( exists $active->{'RULE_REPOSITORY'}, 'Rule Repository exists');
ok( exists $active->{'RULE_REPOSITORY_TYPE'}, 'Rule Repository Type exists');

# Log period
ok( exists $active->{'LOG_PERIOD'}, 'Log Period exists');


# Debug
ok( exists $active->{'DEBUG'}, 'Debug exists');

# Max Servers
ok( exists $active->{'MAX_SERVERS'}, 'Max servers exists');

# KNS Landing Page
ok( exists $active->{'KNS_LANDING_PAGE'}, 'Landing page exists');

# Error MSG
ok( exists $active->{'KNS_ERROR_MSG'}, 'Error message exists');

# Runtime Library 
ok( exists $active->{'RUNTIME_LIB_NAME'}, 'Runtime Library exists');

# Cloudfront
ok( exists $active->{'USE_CLOUDFRONT'}, 'Use cloudfront exists');

# Cache timeout
ok( exists $active->{'CACHEABLE_THRESHOLD'}, 'Cacheable Threshold exists');

# Logging machine
ok( exists $active->{'LOG_SINK'}, 'Log sink exists');

# Logging user
ok( exists $active->{'LOG_ACCOUNT'}, 'Log account exists');

# Dataset root directory
ok( exists $active->{'DATA_ROOT'}, 'Dataset root exists');

# Audit to kverify
ok( exists $active->{'USE_KVERIFY'}, 'KVerify toggle exists');

# KOBJ Constants
ok( exists $active->{'DEFAULT_SERVER_ROOT'}, 'KOBJ default server root exists');
ok( exists $active->{'DEFAULT_ACTION_PREFIX'}, 'KOBJ default action prefix exists');
ok( exists $active->{'DEFAULT_LOG_PREFIX'}, 'KOBJ default log prefix exists');
ok( exists $active->{'DEFAULT_ACTION_HOST'}, 'KOBJ default action host exists');
ok( exists $active->{'DEFAULT_LOG_HOST'}, 'KOBJ default log host exists');
ok( exists $active->{'DEFAULT_JS_ROOT'}, 'KOBJ default js root exists');

# TEMPLATES
ok( exists $active->{'DEFAULT_TEMPLATE_DIR'}, 'Templates for various things');


# Now that basic testing is done, let's compare the active file with our 
# template definitions

# get a copy of the respective config file template
# You can only have one instance of Kynetx::Configure so reload with new file
my $template_file = "./data/$runmode.yml";
Kynetx::Configure::configure($template_file);

my $template = Kynetx::Configure::get_properties();

# if the hashes of the template and the active configuration match
# don't bother doing a deeper validation on the values
SKIP: {
    skip "Deep Template inspection passes",2 if is_deeply($active,$template,'Deep Template comparison'); 
	note ('Active config file mis-match with template definition');

        # Development test suite
	SKIP: {
            skip "Development test suite",1 if ($runmode ne 'development');
            diag("\nDevelopment test suite\n");
	    ok(1,'Always returns true');
	}

        # Production test suite
	SKIP: {
            skip "Production test suite",1 if ($runmode ne 'production');
            diag("\nProduction test suite\n");
            is($active->{'USE_CLOUDFRONT'},1,"Production cloudfront => 1");
	}
    };

done_testing();
1;


