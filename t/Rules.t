#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 2;
use Test::LongString;

use Geo::IP;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rules qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);





# this ought to be read from the httpd-perl.conf file
my $svn_conn = "http://krl.kobj.net/rules/client/|cs|fizzbazz";

# this test relies on a ruleset being available for site 10.
SKIP: {

    # this number must reflect the number of test in this SKIP block
    my $how_many = 1;

    my $site = 10; # the test site.  

    my ($ctx, $svn_url, $rules) ;
    eval {

	$rules = Kynetx::Rules::get_rules_from_repository($site, $svn_conn);
	
    };
    skip "Can't get SVN connection on $svn_conn", $how_many if $@;

    ok(exists $rules->{$site});

}


# This test relies on rulesets test0 and test 1 being identical.
# To test json and krl idempotence and that get_rules_from_repository
# returns .krl or .json as needed, test0 should be .krl and test1
# .json
SKIP: {

    # this number must reflect the number of test in this SKIP block
    my $how_many = 1;


    my ($rules0, $rules1);

    my $site = 'test0'; # the test site.  
    eval {

	$rules0 = Kynetx::Rules::get_rules_from_repository($site, $svn_conn);

	
    };
    skip "Can't get rules from $svn_conn for $site", $how_many if $@;

    $site = 'test1'; # the test site.  
    eval {

	$rules1 = Kynetx::Rules::get_rules_from_repository($site, $svn_conn);
	
    };
    skip "Can't get rules from $svn_conn for $site", $how_many if $@;

    is_deeply($rules0, $rules1);

}

1;


