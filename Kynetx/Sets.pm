package Kynetx::Sets;

# file: Kynetx/Sets.pm
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

use Kynetx::Expressions;
use Kynetx::JSONPath ;
use Kynetx::PrettyPrinter;
use Kynetx::Util qw/split_re/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
  all => [
    qw(
    intersection
    union
    difference
    has
    once
    unique
    duplicates
    from_operator
      )
  ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

sub from_operator {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);
    return $obj unless defined $obj;

    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
    my $a = $obj->{'val'};
    my $b = $rands->[0]->{'val'};
    if (ref $a eq '') {
        my @temp = ();
        push (@temp,$a);
        $a = \@temp;
    }
    if (ref $b eq '') {
        my @temp = ();
        push (@temp,$b);
        $b = \@temp;
    }
    if (ref $a eq 'ARRAY' and ref $b eq 'ARRAY') {
        return ($a,$b);
    } else {
        return undef;
    }  
}

sub intersection {
  my ($a,$b) = @_;
  my $logger = get_logger();
  my $hash;
  map {$hash->{$_}++} @{$a};
  map {$hash->{$_}++} @{$b};
  my @set = grep {$hash->{$_}>1} keys %{$hash};
  return \@set;
}

sub union {
  my ($a,$b) = @_;
  my $logger = get_logger();
  my $hash;
  map {$hash->{$_}++} @{$a};
  map {$hash->{$_}++} @{$b};
  my @set = sort keys %{$hash};
  return \@set;
}

# The foreach appeared fractionally faster than the map in this case
# Will need to benchmark to know for sure
sub difference {
  my ($a,$b) = @_;
  my $logger = get_logger();
  my $hash;
  map {$hash->{$_}++} @{$a};
#  map {delete $hash->{$_}} @{$b};
  foreach (@{$b}) {
      delete $hash->{$_}
  }
  my  @set = sort keys %{$hash};
  return \@set;  
}

sub has {
  my ($a,$b) = @_;
  return 0 if (! (defined $a &&  defined $b) );
  my $logger = get_logger();
  my $hash;
  my $sub_set = scalar @{$b};
  my $x_set = intersection($a,$b);
  my $intr = scalar @{$x_set};
  $logger->trace("Set b: ",$sub_set);
  $logger->trace("xsect: ",$intr);
  if ($sub_set == $intr) {
    return 1;
  } else {
    return 0;
  }
  
}

sub once {
  my ($a) = @_;
  my $logger = get_logger();
  my $hash;
  map {$hash->{$_}++} @{$a};
  my @set = grep {$hash->{$_}==1} keys %{$hash};
  return \@set;
}

sub duplicates {
  my ($a) = @_;
  my $logger = get_logger();
  my $hash;
  map {$hash->{$_}++} @{$a};
  my @set = grep {$hash->{$_}>1} keys %{$hash};
  return \@set;  
}

sub unique {
  my ($a) = @_;
  my $logger = get_logger();
  my $hash;
  map {$hash->{$_}++} @{$a};
  my @set = sort keys %{$hash};
  return \@set;  
}


1;
