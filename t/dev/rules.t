#!/usr/bin/perl -w 
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
use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use File::Find::Rule;

my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";

# Find all Perl files, but don’t look in CVS
my $rule = File::Find::Rule->extras({ follow => 1 });
$rule->or(
    $rule->new->directory->name('CVS')->prune->discard,
    $rule->new->file->name( '*.pl','*.pm','*.t' )
);

my @files = $rule->in( $base );

# set up test plan
my $num_checks = 2; # number of tests inside check subroutine
plan tests => ($#files+1)*$num_checks;

for my $file ( @files ) {
    check( $file );
}

1;

sub check {
    my $filename = shift;
    my $dispname = File::Spec->abs2rel( $filename, $base );

    local $/ = undef;
    open( my $fh, $filename ) or
	return fail( "Couldn't open $dispname: $!" );
    my $text = <$fh>;
    close $fh;

    like( $text, qr/use strict;/, "$dispname uses strict" );
    like( $text, qr/use warnings;|perl -w/,"$dispname uses warnings" );

} # check()
