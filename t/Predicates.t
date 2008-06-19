#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 4;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

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


ok(eval_predicates($Amazon_req_info, \%rule_env, 0, \%rule),
    'testing urban()');

# now make it rural
$rule{'cond'}->[0]->{'predicate'} = 'rural';

ok(! eval_predicates($Amazon_req_info, \%rule_env, 0, \%rule),
    'Testing rural()');


my $Mobile_req_info;
$Mobile_req_info->{'ua'} = 'BlackBerry8320/4.3.1 Profile/MIDP-2.0 Configuration/CLDC-1.1';

# now make it mobile
$rule{'cond'}->[0]->{'predicate'} = 'mobile';

ok(eval_predicates($Mobile_req_info, \%rule_env, 0, \%rule),
   'testing mobile()');

$Mobile_req_info->{'ua'} = '"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12';


ok(! eval_predicates($Mobile_req_info, \%rule_env, 0, \%rule),
   'testing not mobile()');

1;


