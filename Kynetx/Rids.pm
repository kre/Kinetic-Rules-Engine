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
use warnings;

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



1;
