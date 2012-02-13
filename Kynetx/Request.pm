package Kynetx::Request;
# file: Kynetx/Request.pm
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
#use warnings;

use Data::Dumper;
use Log::Log4perl qw(get_logger :levels);
use IPC::Lock::Memcached;

use Kynetx::Rids;

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
    my ($r, $method, $rids, $eventtype, $eid, $options) = @_;

    my $logger = get_logger();

    # grab request params
    my $req = Apache2::Request->new($r);

$logger->debug("Raw request ", sub { Dumper $req->body() });

    my $domain = $req->param('_domain') || $method || 'web';
    $eventtype = $req->param('_type') || $req->param('_name') || $eventtype || 'pageview';

    # we rely on this being undef if nothing passed in
    $rids = $req->param('_rids') || $rids;
    my $explicit_rids = defined $req->param('_rids');

    # endpoint identifier
    my $epi = $req->param('_epi') || 'any';
    # endpoint location
    my $epl = $req->param('_epl') || 'none';

    # manage optional params
    # The ID token comes in as a header in Blue API
    my $id_token = $options->{'id_token'} || $r->headers_in->{'Kobj-Session'};
    my $api = $options->{'api'} || 'ruleset';


    # build initial envv
    my $ug = new Data::UUID;

    my $caller = $req->param('url') || $req->param('caller') || $r->headers_in->{'Referer'} ||  '';


    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/^.*[;]?SESSION_ID=(\w*)[;]?.*$/$1/ if(defined $cookie);


    my $request_info = {

	host => $r->connection->get_remote_host || $req->param('host') || '',
	caller => $caller,  # historical
	page => $caller,
	url => $caller,
	now => time,
	method => $domain,
	# this is also determines the endpint capability type
	domain => $domain,
	eventtype => $eventtype,
        eid => $eid,

	id_token => $id_token,

	explicit_rids => $explicit_rids,

	epl => $epl,
	epi => $epi,
	
        _api => $api,

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
      my $enc = Kynetx::Util::str_in($req->param($n));
      my $kenc = Kynetx::Util::str_in($n);
      $logger->debug("Param $n -> ", $req->param($n), " ", $enc);
      $request_info->{$n} = $enc;
    }

    $request_info->{'param_names'} = \@param_names;

    # handle explicit $rids
    if (defined $rids)  {
      my $rid_array = [];
      foreach my $rid (split(/;/,$rids)) {

	my $rid_info = Kynetx::Rids::mk_rid_info($request_info, $rid);

	push(@{ $rid_array }, $rid_info);
      }
      $rids = $rid_array;
    }

    $request_info->{'rids'} = $rids;
    $request_info->{'site'} = $rids; #historical
    # this will get overridden with a single RID later
    $request_info->{'rid'} = $rids->[0];




    set_capabilities($request_info);

    $logger->debug("Returning request information");

    return $request_info;
}


# merge multiple request environments, last wins
sub merge_req_env {
  my $first = shift;

  # don't overwrite the schedule or bad things happen...
  foreach my $req (@_) {
    foreach my $k (keys %{$req}) {
      $first->{$k} = $req->{$k} unless $k eq 'schedule';
    }
  }
  return $first
}
 
sub log_request_env {
    my ($logger, $request_info) = @_;
    if($logger->is_debug()) {
	foreach my $entry (keys %{ $request_info }) {
	    my $value = $request_info->{$entry};
	    if ($entry eq 'rids' ||
		$entry eq 'site' ||
		$entry eq 'rid'
	       ) {
	      if (ref $value eq 'ARRAY') {
		$value = Kynetx::Rids::print_rids($value);
	      } 
	    } elsif (ref $value eq 'ARRAY') {
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
	  $entry = 'undef' unless defined $entry;
	  $value = 'undef' unless defined $value;
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
      ) ||
      $req_info->{'domain'} eq 'oauth_callback'
     ) {
    $req_info->{'understands_javascript'} = 1;
  }

}

1;
