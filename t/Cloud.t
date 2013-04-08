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
use warnings;

use Test::More;
use Test::LongString;
use Test::WWW::Mechanize;
use HTTP::Cookies;
use Apache2::Const;
use Apache2::Request;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Cloud qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;

use Kynetx::Json qw/:all/;

use Kynetx::Parser;
use Kynetx::Rules;

use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();
my $r = Kynetx::Test::configure();

my $test_count = 0;

my ($krl,$ast,$sm, $ev, $initial, $n1);

## ECI
my $eci = 'a3a23a70-f2a9-012e-4216-00163e411455';
my $other_eci = '44d92880-f2ca-012e-427d-00163e411455';


my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');

sub build_url {
  my($opts) = @_;
  my $ruleset = $opts->{'ruleset'} || 'pds';
  my $function = $opts->{'function'};

  my $params = ["_eci=". ($opts->{'eci'} || $eci) ];
  foreach my $pk ( keys %{$opts->{'params'} } ) {
    unshift(@{ $params }, "$pk=".$opts->{'params'}->{$pk});
  }

  my $url = "http://$platform/sky/cloud/$ruleset/$function?".
		   join("&", @{$params});; 

  return $url;
}
  


my $mech = Test::WWW::Mechanize->new();

# should be empty
#diag Dumper $mech->cookie_jar();


diag "Warning: running these tests on a host without memcache support is slow...";
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = build_url();
    my $response = $ua->get($check_url);
    unless ($response->is_success) {
      diag "skipping server tests: $check_url failed";
      skip "No server available", 0;
    }

    sub test_event_plan {
      my $test_plan = shift;
      my $tc = 0;
      foreach my $test (@{$test_plan}) {
	$logger->debug( "Requesting: ". $test->{'url'});
	my $resp;
	if (defined $test->{'method'} && $test->{'method'} eq 'post') {

	  $resp = $mech->get($test->{'url'});
	} else {
	  #$mech->get_ok($test->{'url'});
	  $resp = $mech->get($test->{'url'});
	}


	diag $mech->content() if $test->{'diag'};
	is($mech->content_type(), $test->{'type'});
	$tc += 1;
	foreach my $like (@{$test->{'like'}}) {
	  my $resp = $mech->content_like($like);
	  if ($resp){
	    $tc++;
	  } else {
	    diag $like;
	    diag $mech->content();
	    diag $test->{'url'};
	    die;
	  }

	}
	foreach my $unlike (@{$test->{'unlike'}}) {
	  my $resp = $mech->content_unlike($unlike);
	  if ($resp){
	    $tc++;
	  } else {
	    diag $unlike;
	    diag $mech->content();
	    diag $test->{'url'};
	    die;
	  }
	}
      }

      return $tc;
    }

    # tests in an event plan are order dependent since events are order dependent.
    # Each plan is running different events in order to test a specific
    #   scenario defined in the rule's select statement
    
    my $test_plan_1 = 
       [{'url' => build_url({'function' => 'get_setting_all'}),
	 'type' => 'application/json',
	 'like' => ['/setSchema/']
	},
	{'url' => build_url({'function' => 'get_setting_foo'}),
	 'type' => 'application/json',
	 'like' => ['/"error":101/']
	},
	{'url' => build_url({'function' => 'get_setting_all',
			     'ruleset' => 'a16x55'
			    }),
	 'type' => 'application/json',
	 'like' => ['/"error":100/']
	},
       ];
    
    $test_count += test_event_plan($test_plan_1);


  }


done_testing($test_count);

1;


