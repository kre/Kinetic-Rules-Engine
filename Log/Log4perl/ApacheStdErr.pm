##################################################
package Log::Log4perl::ApacheStdErr;
##################################################

#use 5.006;
use strict;
#use warnings;

use Log::Log4perl qw(:easy);

sub TIEHANDLE {
    my $class = shift;
    bless [], $class;
}

sub PRINT {
  my $self = shift;
  no warnings;
  my ($str) = @_;
  if ($str =~ /^\[.+\]/) {
    untie *STDERR;
    print STDERR @_;
    tie *STDERR, 'Log::Log4perl::ApacheStdErr';
  }
  eval {$str = join(" ", @_)};
  if ($@) {
    untie *STDERR;
    print STDERR @_;
    print STDERR $@;
    tie *STDERR, 'Log::Log4perl::ApacheStdErr';    
  } 
  if ($str =~ /uninitialized/ ) {
    $Log::Log4perl::caller_depth++;
    TRACE @_;
    $Log::Log4perl::caller_depth--;
    
  } elsif ($str =~ /redefined/ ) {
    $Log::Log4perl::caller_depth++;
    TRACE @_;
    $Log::Log4perl::caller_depth--;
    
  } else {
  $Log::Log4perl::caller_depth++;
  DEBUG @_;
  WARN $str;
  $Log::Log4perl::caller_depth--;
  }
}
    
1;
