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



use APR::Table ();

use ModPerl::Registry ();

use Apache2::Const -compile => ':common';
use APR::Const -compile => ':common';

use Apache::Session::DB_File;

srand( time() ^ ($$ + ($$ <<15)) );

use Geo::IP;

1;
