package Kynetx::PersistentDataService;
# file: Kynetx/PersistentDataService.pm
# file: Kynetx/Predicates/Referers.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);

use JSON::XS;

use Kynetx::Util qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Persistence qw(save_persistent_var);
use Apache2::Const;
use Data::Dumper;
$Data::Dumper::Indent = 1;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    Kynetx::Util::config_logging($r);

    my $logger = get_logger();

    $r->content_type('text/javascript');

    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my $method;
    my $sid = 'unknown';
    my $rid = 'unknown';
    my $vars = 'unknown';

    ($method,$rid,$sid, $vars) =
      $r->path_info =~
	m!/(get|store|version)(?:/([A-Za-z0-9_;]+)/([A-Za-z0-9_]+)/([A-Za-z0-9_;]+)/?)?!;

    $logger->debug("processing method $method on RID $rid and session $sid with vars $vars");
    Log::Log4perl::MDC->put('site', $rid);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    # store these for later logging
    $r->subprocess_env(METHOD => $method);
    $r->subprocess_env(SID => $sid);

    # get session
    my $session = process_session($r, $sid);

    my $req = Apache2::Request->new($r);

    my $val = $req->param('val');


    # at some point we need a better dispatch function
    if($method eq 'version' ) {
      show_build_num($r, $method, $rid);
    } elsif ($method eq 'get' ) {
      $logger->debug("Session ", sub {Dumper $session});
      print get_values($rid, $session, $vars);
    } elsif ($method eq 'store' ) {
      $logger->debug("Session ", sub {Dumper $session});
      print store_values($rid, $session, $vars, $val)
    }

    return Apache2::Const::OK;
}

sub get_values {
  my ($rid, $session, $vars) = @_;

  return astToJson({$vars => Kynetx::Persistence::get_persistent_var("ent",$rid, $session, $vars)});
}

sub store_values {
  my ($rid, $session, $vars, $val) = @_;

  my $logger = get_logger();

  $logger->debug("Storing $vars => $val");

  # try to decode it as JSON
  my $nval = eval { jsonToAst($val) };
  $nval = $val if ($@);

  return astToJson({$vars => Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $vars, $nval)});

}



1;
