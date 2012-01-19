package Bundle::kobj_modules;

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

$VERSION = '1.00';

1;

__END__

=head1 NAME

Bundle::kobj_modules - A bundle to install all the modules kobj uses

=head1 SYNOPSIS

In the directory containing the C<Bundle/> directory:

C<perl -MCPAN -e 'install Bundle::kobj_modules'>

Note this Bundle is not on CPAN yet.

=head1 CONTENTS

URI

LWP

Digest::MD5

URI::Escape

DateTime

ModPerl::Registry

JSON::XS

XML::XPath

Test::LongString

Getopt::Std

Data::Dumper

Apache::Session::DB_File

Apache::Session::Memcached

Test::More

APR::Table

Log::Log4perl

Log::Dispatch::File

Log::Dispatch::Screen

ModPerl::Util

HTML::Template

LWP::Simple

File::Find::Rule

Apache2::RequestRec

Apache2::xForwardedFor

Cache::Memcached

Apache::DBI

ExtUtils::XSBuilder

JavaScript::Minifier

Data::UUID

Mobile::UserAgent

Text::CSV

Sys::Hostname

=head1 DESCRIPTION

This bundle is to install all the non-required modules that
the Kynetx uses.  

Geo::IP is not installed since it needs the C library installed first.  

Apache2::Request is not installed since it needs arguments to it's build

=head1 AUTHOR

Phil Windley E<lt>F<windley@kynetx.com>E<gt>

=cut
