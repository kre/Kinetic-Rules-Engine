#!/usr/bin/perl -w 
# check that all required modules are available

use strict;

use lib qw(/web/lib/perl);

use Test::More;
use Test::LongString;
use File::Find::Rule;

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
my $rule = File::Find::Rule->new;
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


@mods = keys %modules;

diag("Using the following modules");
diag(join "\n", @mods);

# set up test plan
plan tests => ($#mods+1);


for my $module ( @mods ) {
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
	if($s =~ s/^use\s+([^ ]+).*;.*/$1/) {
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
