package Kynetx::Persistence::DevLog;
# file: /Log/Log4perl/MongoDB.pm
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
use lib qw(
    /web/lib/perl
);


use Log::Log4perl qw(get_logger :levels);
use DateTime;
use JSON::XS;
use Data::Dumper;
$Data::Dumper::Indent = 1;

use Schedule::Cron::Events;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Session qw(:all);
use Kynetx::Request qw( build_request_env );
use Kynetx::Configure qw(:all);
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use Kynetx::Persistence::KEN;
use Kynetx::Persistence::KToken qw(:all);
use Kynetx::Modules::Event;
use Kynetx::Cloud qw( unalias );


use MongoDB;
use MongoDB::OID;
use Digest::MD5 qw(
    md5_base64
);
use Data::UUID;
use Apache2::Const -compile => qw(OK DECLINED);
use Time::Local qw(timelocal);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use constant TOKEN_NAME => "Active Logging";
use constant SKIP_RIDS => [ "b16x29" ];

our $collection = Kynetx::Configure::get_config('MONGO_LOG') || 'devlog';

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
  create_logging_eci
  has_logging
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub handler {
  my $r = shift;	
  my $logger = get_logger();
  my ( $domain, $eventtype, $eid, $rids, $id_token, $req_info );
  my @path_components = split( /\//, $r->path_info );
  $logger->debug("Path on logging: ", $r->path_info);

  if ($path_components[1] eq "event") {
    my $id_token = $path_components[2];
    my $eid = $path_components[3] || '';

    # optional...usually passed in as parameters
    my $domain    = $path_components[4];
    my $eventtype = $path_components[5];
    # build the request data structure. No RIDs yet. (undef)
    $req_info = Kynetx::Request::build_request_env(
						   $r, $domain, $rids,
						   $eventtype,
						   $eid,
						   {
						    'api'      => 'sky',
						    'id_token' => $id_token
						   }
						  );
  } else { # cloud
    $req_info = Kynetx::Request::build_request_env($r, $path_components[4], $rids, undef, int(rand(999999999999)) );
    my ($module_alias, $version) = split(/\./,$path_components[2]);
    my $rid = Kynetx::Cloud::unalias($module_alias);
    $logger->debug("Sky Cloud logging with rid ", sub{Dumper $rid});

    $req_info->{'module_name'} = $rid;
    $req_info->{'rid'} = Kynetx::Rids::mk_rid_info( $req_info, $rid );
    $req_info->{'module_version'} = $version;
    $req_info->{'module_alias'} = $module_alias;
    $req_info->{'function_name'} = $path_components[3];

  }

  # use pnotes from handlers
  $req_info->{"eid"} = $r->pnotes("EID");
  $req_info->{"rids"} = Kynetx::Rids::parse_rid_list($req_info, $r->pnotes("RIDS")) || [] ;

  # Kynetx::Request::log_request_env( $logger, $req_info );
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($req_info->{"id_token"});
#  $logger->debug("KEN: $ken");
  if ($ken) {
    my $list = Kynetx::Persistence::KToken::get_token_by_ken_and_label($ken, TOKEN_NAME);
    ###$logger->debug("Seeing these DECIs ", sub{Dumper $list});
    my $logging_token = $list->[0];
    $logger->debug("Logging token: ", $logging_token);

    my $skip_rids = { map { $_ => 1 } @{ (SKIP_RIDS) } };

    my $logging_rid = 0;

    # don't flush logging some dires (in skip list) to mongo log
    if (  defined $req_info->{'function_name'} ) {
      $logging_rid =  $skip_rids->{Kynetx::Rids::get_rid($req_info->{"rid"})}
    } else {
      $logging_rid =  length( @{ $req_info->{"rids"} || [] } ) == 1
                   && $skip_rids->{Kynetx::Rids::get_rid($req_info->{"rids"}->[0])}
    }

    # $logger->debug("SKIP: ", sub{ Dumper  $req_info->{"rids"} } );

    if ($logging_token && ! $logging_rid) {
	Log::Log4perl::MDC->put( '_ECI_',  $logging_token);
	Log::Log4perl::MDC->put( 'eid',  $req_info->{'eid'});
	$logger->debug("__DEVLOG__"); # write the trigger to the log (see log.conf for Log4Perl)
    } else {
	$logger->debug("Dev Log not writing");
    }
  }
  return Apache2::Const::OK;
}


sub get_all_msg {
  my ($eci) = @_;
  my $logger = get_logger();
  my $list;
  my $tkey = _all($eci);
  my $c = Kynetx::MongoDB::get_collection($collection);
  my $count = $c->count();
  my $cursor = $c->query($tkey)->sort({'$natural' => 1});
  $logger->debug("Found: ($eci) ", $cursor->count());
  while (my $obj = $cursor->next) {
    my $id = $obj->{'_id'}->to_string;
    push @{$list}, _normalize($obj);
  }
  my @result = sort {$b->{"created"} <=> $a->{"created"}} @{ $list || [] };
#  my @result = reverse @{ $list || [] };
  return \@result;
}

sub get_active {
  my ($eci) = @_;
  my $logger = get_logger();
  my $list;
  
  my $c = Kynetx::MongoDB::get_collection($collection);
  my $tkey = _active($eci);
  my $cursor = $c->query($tkey)->sort({'$natural' => 1});
  while (my $obj = $cursor->next) {
    my $id = $obj->{'_id'}->to_string;
    push @{$list}, _normalize($obj);
  }
  my @result = sort {$b->{"created"} <=> $a->{"created"}} @{ $list || [] };
#  my @result = reverse @{ $list || [] };
  return \@result;
}

sub get_log {
  my ($eci,$log_id) = @_;
  my $logger=get_logger();
  my $c = Kynetx::MongoDB::get_collection($collection);
  my $key = _single($eci,$log_id);
  my $obj = $c->find_one($key);
  if (defined $obj && ref $obj eq "HASH") {
    return _normalize($obj);
  } 
  return undef;
}

sub delete_log {
  my ($eci,$log_id) = @_;
  my $logger=get_logger(); 
  my $c = Kynetx::MongoDB::get_collection($collection);
  my $key = _single($eci,$log_id);
  my $status = $c->remove($key);
}

sub _active {
  my ($eci) = @_;
  my $ttl_index = Kynetx::Configure::get_config('MONGO_TTL_INDEX');
  my $tkey = {'$and' => [{$ttl_index => {'$exists' => 0}}, {'eci' => $eci}]};
  return $tkey
}

sub _all {
  my ($eci) = @_;
  my $tkey = {'eci' => $eci};
  return $tkey;  
}

sub _single {
  my ($eci,$log_id) = @_;
  my $mid = MongoDB::OID->new(value => $log_id);
  my $tkey = {'$and' => [{'eci' => '$id' => $mid}]};
  return $tkey;
}

sub flush {
  my ($eci) = @_;
  my $logger = get_logger();
  my $c = Kynetx::MongoDB::get_collection($collection);
  my $result = $c->remove({'eci' => $eci});
  return $result
}

sub _normalize {
  my ($obj) = @_;
  my $eid = $obj->{"eid"};
  my $skip_rids = join("|", @{ (SKIP_RIDS) } );
  my $logger = get_logger();
  $logger->debug("Skip RIDS ", sub{ Dumper $skip_rids });
  my @items = grep(!/$skip_rids/, grep(/^\d+\s+$eid\s+/,split(/\n/,$obj->{'text'})));
  my $timestamp = DateTime->from_epoch( epoch => $obj->{'created'} );
  my $struct = {
    'id' => $obj->{"_id"}. "",
    'created' => $obj->{'created'} ,
    'eid' => $obj->{"eid"},
    'timestamp' =>  $timestamp. "",
#    'log_text' => $obj->{'text'}
    'log_items' => \@items
  };
  return $struct;
}

sub create_logging_eci {
  my ($ken) = @_;
  clear_logging_eci($ken); # we only want one!!
  my $eci = Kynetx::Persistence::KToken::create_token($ken,TOKEN_NAME,$collection);
  return $eci;
}

sub clear_logging_eci {
  my ($ken) = @_;
  my $list = Kynetx::Persistence::KToken::get_token_by_ken_and_label($ken, TOKEN_NAME);
#  my $logger = get_logger();
#  $logger->debug("Seeing these DECIs ", sub{Dumper $list});
  foreach my $eci (@{$list}) {
    Kynetx::Persistence::KToken::delete_token($eci);
  }
}

sub has_logging {
    my ($ken) = @_;
    my $logger = get_logger();
    my $list = Kynetx::Persistence::KToken::get_token_by_ken_and_label($ken, TOKEN_NAME);
    $logger->debug("Logging eci: ", sub {Dumper($list)});
    if (defined $list && ref $list eq "ARRAY" && scalar @{$list} >= 1) {
	return 1
    } else {
	return 0;
    }
}


1;
