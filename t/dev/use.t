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
use strict;

use lib qw(
/web/lib/perl
/web/etc
);

use Test::More;
use Test::LongString;
use File::Find::Rule;

use Apache2::Const;

use Kynetx::Test qw/:all/;

# will ignore things in this list
my $pragmas = {
    'use' => 1,
    'lib' => 1,
    'strict' => 1,
    'vars' => 1,
    'warnings' => 1,
    'base' => 1,
    'require' => 1,
    'constant' => 1,
};

my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";

# Find all Perl files, but don’t look in CVS
my $rule = File::Find::Rule->extras({ follow => 1 });
$rule->or(
    $rule->new->directory->name('CVS')->prune->discard,
    $rule->new->file->name( '*.pl','*.pm','*.t' )
);

my @files = $rule->in( $base );

# gather up the modules
my @mods;
for my $file ( @files ) {
    push @mods, get_modules($file);
}

# uniq
my %modules;
for my $module ( @mods ) {
    $module = trim($module);
    $modules{$module} = 1 unless $pragmas->{$module};
}

# Sort this because smoke dev/use.t hates when PCI.pm comes first
@mods = sort keys %modules;

#diag("Using the following modules");
#diag(join "\n", @mods);

# set up test plan
plan tests => ($#mods+1);


for my $module ( @mods ) {
    #diag $module;
    require_ok($module);
}

1;

sub get_modules {
    my $filename = shift;
    my $dispname = File::Spec->abs2rel( $filename, $base );

    open( my $fh, $filename ) or
	return fail( "Couldn't open $dispname: $!" );

    my @modules;
    while(my $s = <$fh>) {
	if($s =~ s/^use\s+([^ ;]+).*;.*/$1/) {
	    push(@modules, $s);
	} else {
	    next;
	}
    }

    close $fh;

    return @modules;
}

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
