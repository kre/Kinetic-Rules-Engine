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

Test::More

APR::Table

HOP::Lexer

HOP::Stream

Log::Log4perl

Log::Dispatch::File

Log::Dispatch::Screen

ModPerl::Util

HTML::Template

LWP::Simple

File::Find::Rule

Apache2::RequestRec


=head1 DESCRIPTION

This bundle is to install all the non-required modules that
the Kynetx uses.  

Geo::IP is not installed since it needs the C library installed first.  

=head1 AUTHOR

Phil Windley E<lt>F<phil@kynetx.com>E<gt>

=cut
