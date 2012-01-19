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


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
    mk_rid_info
    get_rid
    get_version
    parse_rid_list
    print_rids
    rid_info_string
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub mk_rid_info {
  my($req_info,$rid, $options) = @_; 

  my $version = 
       $options->{'version'} ||
	 $req_info->{"$rid:kynetx_app_version"} || 
	   $req_info->{"$rid:kinetic_app_version"} || 
	     'prod';


  return {'rid' => $rid,
	  'kinetic_app_version' => $version};
}

sub get_rid {
  my($rid_info) = @_;
  return $rid_info->{'rid'};
}

sub get_version {
  my($rid_info) = @_;
  return $rid_info->{'kinetic_app_version'} || 'prod';
}

sub get_versionnum {
  my($rid_info) = @_;
  return $rid_info->{'version'};
}


# a string rid list looks like "foo.234;bar.dev"
# alternately, we might get an array of strings ["foo.234"; "bar.dev"]
sub parse_rid_list {
  my($req_info, $rid_list) = @_;
  # if not array, assume its a semicolon delimited string
  unless ( ref $rid_list eq 'ARRAY') {
    $rid_list = [split(/;/, $rid_list)];
  }
  # normalize, split might not always return an array, make it one
  # unless ( ref $rid_list eq 'ARRAY' ) {
  #   $rid_list = [$rid_list];
  # }
  my $rid_info_list;
  foreach my $rid_and_ver (map { split( /\./, $_, 2 ) } @{$rid_list}) {
    my ( $rid, $ver );
    if ( ref $rid_and_ver eq 'ARRAY' ) {
      ( $rid, $ver ) = @{$rid_and_ver};
    } else {
      ( $rid, $ver ) = ( $rid_and_ver, 0 );
    }
    push(@{ $rid_info_list }, 
	 mk_rid_info($req_info, $rid, {'version' => $ver})
	);
	
  }
  return $rid_info_list;
}

sub print_rid_info {
  my($rid_info) = @_;

  return get_rid($rid_info).".".get_version($rid_info)
}

sub rid_info_string {
  my($rid_info_list) = @_;
  my $res = "";
  foreach my $rid_info ( @{$rid_info_list}) {
    $res .= get_rid($rid_info).".".get_versionnum($rid_info).';';
  }
  return $res;
}

# prints an array of rid_info hashes as "foo.234;bar.dev"
sub print_rids {
  my($rid_info) = @_;
  my $res = "";
  foreach my $rid ( @{$rid_info}) {
    $res .= print_rid_info($rid).";";
  }
  return $res;
}

1;
