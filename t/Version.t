#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();

use JSON::XS;
use Cwd;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Version qw/:all/;
use Kynetx::JavaScript qw/:all/;



my $BYU_req_info;
$BYU_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$BYU_req_info->{'pool'} = APR::Pool->new;

my $no_referer_req_info;
$no_referer_req_info->{'pool'} = APR::Pool->new;

my %rule_env = ();

plan tests => 1;

like(get_build_num(cwd()),qr/\d+/,"we get some numbers back");


1;


