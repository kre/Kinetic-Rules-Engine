#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::JavaScript qw/:all/;



plan tests => 11;


Kynetx::Configure::configure("./data/kns_config.yml");

is(get_config('KOBJ_ROOT'), '/web/lib/perl');

is(get_config('SERVER_ADMIN'), 'web@kynetx.com');

is(get_config('SESSION_SERVERS'), '127.0.0.1:11211 192.168.122.1:11211');

is_deeply(get_config('MEMCACHE_SERVERS'), ['127.0.0.1:11211']);

is(get_config('COOKIE_DOMAIN'), '127.0.0.1');

is(get_config('USE_CLOUDFRONT'), 0);

is(get_config('CACHEABLE_THRESHOLD'), 86400);

contains_string(join(" ", @{ config_keys() }), 'CB_HOST');
contains_string(join(" ", @{ config_keys() }), 'MAX_SERVERS');
contains_string(join(" ", @{ config_keys() }), 'SESSION_SERVERS');
contains_string(join(" ", @{ config_keys() }), 'EVAL_HOST');

1;


