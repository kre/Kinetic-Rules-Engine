#!/usr/lib/perl -w

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
use strict;
use lib qw(/web/lib/perl);
no warnings;


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


# use Geo::IP ();
use Time::HiRes qw(time);
use Data::UUID ();

use Apache::DBI ();
use DBI ();

# AnyEvent
use AnyEvent ();
use AnyEvent::HTTP ();

use URI::Escape ();

#use SVN::Client;

# preload Kynetx code
use Kynetx::Actions ();
use Kynetx::Authz ();
use Kynetx::Console ();
use Kynetx::Datasets ();
use Kynetx::JavaScript ();
use Kynetx::Errors ();
use Kynetx::Expressions ();
use Kynetx::Json ();
use Kynetx::Log ();
use Kynetx::Memcached ();
use Kynetx::Parser ();
use Kynetx::Modules ();
use Kynetx::PrettyPrinter ();
#use Kynetx::Repository ();
use Kynetx::Request ();
use Kynetx::RuleManager ();
use Kynetx::Rules ();
use Kynetx::Session ();
use Kynetx::Util ();
use Kynetx::Version ();
use Kynetx::Configure ();
use Kynetx::Postlude ();
use Kynetx::Keys ();


use Log::Log4perl ();
use Log::Log4perl::Appender::ErrorStack ();
# initialize Log4perl
#use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->init_and_watch('/web/lib/perl/log4perl.conf', 60);

srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip -f`);
# srand( time() ^ ($$ + ($$ <<15)) );

# filter chatty stderr msgs
use Log::Log4perl::ApacheStdErr;
tie *STDERR, "Log::Log4perl::ApacheStdErr";

# configure KNS
Kynetx::Configure::configure();


1;
