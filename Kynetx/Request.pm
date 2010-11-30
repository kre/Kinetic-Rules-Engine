package Kynetx::Request;
# file: Kynetx/Request.pm
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

use Data::Dumper;
use Log::Log4perl qw(get_logger :levels);
use IPC::Lock::Memcached;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
build_request_env
log_request_env
merge_request_env
set_capabilities
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub build_request_env {
    my ($r, $method, $rids, $eventtype) = @_;

    my $logger = get_logger();

    # grab request params
    my $req = Apache2::Request->new($r);

    # build initial envv
    my $ug = new Data::UUID;

    my $caller = $req->param('caller') || $r->headers_in->{'Referer'} ||  '';
    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/^.*[;]?SESSION_ID=(\w*)[;]?.*$/$1/ if(defined $cookie);

    my $request_info = {

	host => $r->connection->get_remote_host || $req->param('host') || '',
	caller => $caller,  # historical
	page => $caller,
	now => time,
        rids => $rids,
	site => $rids, #historical
	# this will get overridden with a single RID later
	rid => $rids,

	method => $method,
	# this is also determines the endpint capability type
	domain => $method,
	eventtype => $eventtype,

	hostname => $r->hostname(),
	ip => $r->connection->remote_ip() || '0.0.0.0',
	ua => $r->headers_in->{'User-Agent'} || '',
	pool => $r->pool,
	uri => $r->uri(),

	# set the default major and minor version for this endpoint
	# these may get overridden by parameters below
        majv => 0,
        minv => 0,

	txn_id => $ug->create_str(),
	g_id => $cookie,

	# directives
	directives => [],
	};


    my @param_names = $req->param;
    foreach my $n (@param_names) {
#	$logger->debug("Param $n -> ", $req->param($n));
	$request_info->{$n} = $req->param($n);
    }
    $request_info->{'param_names'} = \@param_names;

    set_capabilities($request_info);

#    my $patience = Kynetx::Configure::get_config("LOCK_PATIENCE");
#    my $l_ttl = Kynetx::Configure::get_config("LOCK_TTL");
#    my $memservers = Kynetx::Configure::get_config('MEMCACHE_SERVERS');
#    $request_info->{'_lock'} = IPC::Lock::Memcached->new({
#        "memcached_servers" => $memservers,
#        "patience" => $patience,
#        "ttl" => $l_ttl,
#    });

    $logger->debug("Returning request information");

    return $request_info;
}

sub merge_req_env {
  my $first = shift;
  foreach my $req (@_) {
    foreach my $k (keys %{$req}) {
      $first->{$k} = $req->{$k};
    }
  }
  return $first
}

sub log_request_env {
    my ($logger, $request_info) = @_;
    if($logger->is_debug()) {
	foreach my $entry (keys %{ $request_info }) {
	    my $value = $request_info->{$entry};
	    if (ref $value eq 'ARRAY') {
	        my @tmp = map {substr($_,0,50)} @$value;
	        $value = '[' . join(',',@tmp) . ']';
	    } else {
	        if ($value) {
	            $value = substr($value,0,50);
	        } else {
	            $value = '';
	        }

	    }
	  # print out first 50 chars of the request string
	  $logger->debug("$entry:$value");

	}
# 	foreach my $h (keys %{ $r->headers_in }) {
# 	    $logger->debug($h . ": " . $r->headers_in->{$h});
# 	}
    }


}


sub set_capabilities {
  my $req_info = shift;
  my $capspec = shift;

  my $logger = get_logger();

  $capspec = Kynetx::Configure::get_config('capabilities') unless $capspec;

#  $logger->debug("Cap spec ", sub { Dumper $capspec });

  if ($capspec->{$req_info->{'domain'}}->{'capabilities'}->{'understands_javascript'} ||
      $req_info->{'domain'}  eq 'eval' || # old style evaluation
      ($req_info->{'domain'} eq 'web' &&
       ! defined $capspec->{'web'}->{'capabilities'}->{'understands_javascript'}
      )
     ) {
    $req_info->{'understands_javascript'} = 1;
  }

}

1;
