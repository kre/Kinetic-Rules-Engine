#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 2;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates qw/:all/;
use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);


my %rule_env = ();


my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

# check some predicates from Demographics
my %rule = (
    'cond' => [
	{'predicate' => 'urban',
	 'args' => [],
	 'type' => 'simple'
	}
	]
    );


ok(eval_predicates($Amazon_req_info, \%rule_env, 0, \%rule));

# now make it rural
$rule{'cond'}->[0]->{'predicate'} = 'rural';

ok(! eval_predicates($Amazon_req_info, \%rule_env, 0, \%rule));

1;


