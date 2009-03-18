#!/usr/lib/perl -w

use strict;
use lib qw(/web/lib/perl);


# preload all mp2 modules
# use ModPerl::MethodLookup;
# ModPerl::MethodLookup::preload_all_modules();
  
use ModPerl::Util (); 

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::RequestUtil ();

use Apache2::ServerRec ();
use Apache2::ServerUtil ();
use Apache2::Connection ();
use Apache2::Log ();
use APR::URI ();

use Apache2::xForwardedFor ();



use APR::Table ();

use ModPerl::Registry ();

use Apache2::Const -compile => ':common';
use APR::Const -compile => ':common';

use Apache::Session::Memcached;

use Apache2::Request ();



use Geo::IP ();
use Time::HiRes qw(time);
use Data::UUID ();

use Apache::DBI ();
use DBI ();

# preload Kynetx code
use Kynetx::Actions ();
use Kynetx::Console ();
use Kynetx::Datasets ();
use Kynetx::JavaScript ();
use Kynetx::Json ();
use Kynetx::Log ();
use Kynetx::Memcached ();
use Kynetx::Parser ();
use Kynetx::Predicates ();
use Kynetx::PrettyPrinter ();
use Kynetx::Repository ();
use Kynetx::Request ();
use Kynetx::RuleManager ();
use Kynetx::Rules ();
use Kynetx::Session ();
use Kynetx::Util ();
use Kynetx::Version ();


# initialize Log4perl
#use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->init_and_watch('/web/lib/perl/log4perl.conf', 60);

srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip -f`);
# srand( time() ^ ($$ + ($$ <<15)) );


1;
