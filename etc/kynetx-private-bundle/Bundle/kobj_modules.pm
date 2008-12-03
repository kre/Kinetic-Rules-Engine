package Bundle::kobj_modules;

use strict;
use warnings;

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
