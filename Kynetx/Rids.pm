package Kynetx::Rids;

# file: Kynetx/Rids.pm
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

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
  all => [
    qw(
      mk_rid_info
      get_rid
      get_version
      get_uri
      get_username
      get_password
      get_header
      parse_rid_list
      print_rids
      rid_info_string
      get_rid_from_context
      get_rid_info_from_registry
      get_rid_info_by_rid
      version_default
      )
  ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );


sub mk_rid_info {
  my ( $req_info, $rid, $options ) = @_;
  my $logger = get_logger();
  my $parent = (caller(1))[3];
  
  $logger->trace("Make rid info for $rid");
  
  my $version = $options->{'version'}
      || Kynetx::Request::get_attr( $req_info, "$rid:kynetx_app_version" )
      || Kynetx::Request::get_attr( $req_info, "$rid:kinetic_app_version" )
      || Kynetx::Rids::version_default();
  

  my $rid_info = Kynetx::Persistence::Ruleset::rid_info_from_ruleset($rid,$version);
  
  if ( defined $rid_info ) {
    return {
      'rid'                 => get_rid($rid_info),
      'kinetic_app_version' => get_version($rid_info)
    };
  } else {
    return {
      'rid'                 => $rid,
      'kinetic_app_version' => $version
    };

  }
}

sub to_rid_info {
  my ($fqrid) = @_;
  my ($rid,$ver) = split(/\./,$fqrid,2);
  $ver ||= Kynetx::Rids::version_default();
  return {
    'rid'                 => $rid,
    'kinetic_app_version' => $ver
  };
  
}


sub get_current_rid_info {
  my ($req_info) = @_;
  return $req_info->{'rid'};
}

sub get_rid {
  my ($rid_info) = @_;
  my $logger = get_logger();
  my $parent = (caller(1))[3];
  #$logger->trace("Get rid ($parent): ", sub {Dumper($rid_info)});
  if (ref $rid_info eq "HASH") {
    return _clean($rid_info->{'rid'});
  } else {
    return _clean($rid_info)
  }
  
}

sub _clean {
  my ($rid) = @_;
  my ($crid,$extra);
  if ($rid =~ m/\./) {
    ($crid,$extra) = split(/\./,$rid,2);
    return $crid;
  } 
  return $rid;
  
}

sub get_version {
  my ($rid_info) = @_;
  my $logger = get_logger();
  my $parent = (caller(1))[3];
  #$logger->trace("Get version ($parent): ", sub {Dumper($rid_info)});
  if (ref $rid_info eq "HASH") {
    return $rid_info->{'kinetic_app_version'} || Kynetx::Rids::version_default();
  }
  return $rid_info->{'kinetic_app_version'} || Kynetx::Rids::version_default();
}

sub get_fqrid {
  my ($rid_info) = @_;
  my $logger = get_logger();
  my $parent = (caller(1))[3];
  #$logger->trace("Get fqrid ($parent): ", sub {Dumper($rid_info)});
  my $rid = get_rid($rid_info);
  my $ver = get_version($rid_info);
  return $rid . '.' . $ver;
}

sub make_fqrid {
  my ($rid,$tag) = @_;
  $tag = version_default() unless ($tag);
  my $fqrid = $rid . '.' . $tag;
  return $fqrid;
}

sub get_versionnum {
  my ($rid_info) = @_;
  return $rid_info->{'version'};
}

sub get_uri {
  my ($rid_info) = @_;
  if (ref $rid_info eq "HASH") {
    return $rid_info->{'uri'};
  } else {
    return undef;
  }
  
}

sub get_username {
  my ($rid_info) = @_;
  return $rid_info->{'username'};
}

sub get_password {
  my ($rid_info) = @_;
  return $rid_info->{'password'};
}

sub get_header {
  my ( $rid_info, $header ) = @_;
  if ( defined $header ) {
    return $rid_info->{'headers'}->{$header};
  }
  else {
    return $rid_info->{'headers'};
  }
}

# a string rid list looks like "foo.234;bar.dev"
# alternately, we might get an array of strings ["foo.234"; "bar.dev"]
sub parse_rid_list {
  my ( $req_info, $rid_list ) = @_;

  #  my $logger = get_logger();

  # if not array, assume its a semicolon delimited string
  unless ( ref $rid_list eq 'ARRAY' ) {
    $rid_list = [ split( /;/, $rid_list ) ];
  }

  #  $logger->debug("parsing rid list ", sub{Dumper $rid_list});

  # normalize, split might not always return an array, make it one
  # unless ( ref $rid_list eq 'ARRAY' ) {
  #   $rid_list = [$rid_list];
  # }
  my $rid_info_list;
  foreach my $rid_and_ver ( map { [ split( /\./, $_, 2 ) ] } @{$rid_list} ) {
    my ( $rid, $ver );
    if ( ref $rid_and_ver eq 'ARRAY' ) {
      ( $rid, $ver ) = @{$rid_and_ver};
    }
    else {
      ( $rid, $ver ) = ( $rid_and_ver, 0 );
    }
    push(
      @{$rid_info_list},
      mk_rid_info( $req_info, $rid, { 'version' => $ver } )
    );

  }
  return $rid_info_list;
}

sub print_rid_info {
  my ($rid_info) = @_;
  my $rid = get_rid($rid_info);
  my $ver = get_version($rid_info);
  return make_fqrid($rid,$ver);
}

sub rid_info_string {
  my ($rid_info_list) = @_;
  my $res = "";
  foreach my $rid_info ( @{$rid_info_list} ) {
    $res .= get_rid($rid_info) . "." . get_versionnum($rid_info) . ';';
  }
  return $res;
}

# prints an array of rid_info hashes as "foo.234;bar.dev"
sub print_rids {
  my ($rid_info) = @_;
  my $res = "";
  foreach my $rid ( @{$rid_info} ) {
    $res .= print_rid_info($rid) . ";";
  }
  return $res;
}

sub get_rid_from_context {
  my ( $rule_env, $req_info ) = @_;
  my $logger = get_logger();
  my $inModule = Kynetx::Environments::lookup_rule_env( '_inModule', $rule_env )
    || 0;
  my $moduleRid =
    Kynetx::Environments::lookup_rule_env( '_moduleRID', $rule_env );
  my $rid = get_rid( $req_info->{'rid'} );
  if ($inModule) {
    $logger->debug("Evaling persistent in module: $moduleRid");
  }

  # $logger->trace("**********in module: $inModule");
  # $logger->trace("**********module Rid: $moduleRid");
  # $logger->trace("**********calling Rid: $rid");
  if ( defined $moduleRid ) {
    $rid = $moduleRid;
  }
  return $rid;
}

sub version_default {
  my $default = Kynetx::Configure::get_config('KNS_DEFAULT_VERSION');
  if ($default) {
    return $default
  } else {
    return 'prod';
  }
}

1;
