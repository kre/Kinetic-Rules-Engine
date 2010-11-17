package Kynetx::PersistentDataService;
# file: Kynetx/PersistentDataService.pm
# file: Kynetx/Predicates/Referers.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
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
    config_logging($r);

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
