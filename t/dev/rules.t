#!/usr/bin/perl -w 
# check that all perl files meet programming rules

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
