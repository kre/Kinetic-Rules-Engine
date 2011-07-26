#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Directives qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);
$my_req_info->{'directives'} = [];

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;



send_directive($my_req_info, 
	       "emit_js", 
	       {'js' => 'var domain = $K(obj).data("domain");'});

is($my_req_info->{'directives'}->[0]->type(), "emit_js");
$test_count++;


is_deeply($my_req_info->{'directives'}->[0]->options(), 
	  {'js' => 'var domain = $K(obj).data("domain");'}
  );
$test_count++;


emit_js($my_req_info, 
	'var domain = $K(obj).data("domain");');


is_deeply($my_req_info->{'directives'}->[0]->options()->{'js'}, 
	  $my_req_info->{'directives'}->[1]->options()->{'js'}, 
	 );
$test_count++;

my $vars = {'a' => 5, 'b' => ['a', 'foo']};

send_data($my_req_info,
	  $vars
	 );


is_deeply($my_req_info->{'directives'}->[2]->options(), 
	  $vars
	 );
$test_count++;

#diag (Dumper to_directive($my_req_info->{'directives'}->[2], $my_req_info->{'eid'}));

is_deeply(to_directive($my_req_info->{'directives'}->[2], $my_req_info->{'eid'}),
	  {'options' => {'a' => 5,
			 'b' => [
				 'a',
				 'foo'
				]
			},
	   'name' => 'data',
	   'meta' => {'eid' => '0123456789abcdef'},
	  });
$test_count++;

done_testing($test_count);



1;


