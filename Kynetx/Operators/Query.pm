package Kynetx::Operators::Query;
# file: Kynetx/Operators/Query.pm
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

use HTML::Query qw(Query);
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Storable qw(dclone);

use Kynetx::Expressions;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    query
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub query {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj =
        Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);
    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
    #my $intpr = Kynetx::Expressions::eval_expr($rands->[0], $rule_env, $rule_name,$req_info, $session);
    #my $sel_obj = Kynetx::Expressions::den_to_exp(dclone($intpr));
    #my $selector = make_selector($sel_obj);
    my $selector = make_selector($rands->[0],$rule_env, $rule_name,$req_info, $session);
    my $format = "as_HTML";
    if ($rands->[1]->{'val'}){
        $format = "as_text";
    }
    my $source = make_source($obj);
    my $q = HTML::Query->new($source );
    my @elements = $q->query($selector)->$format;
    return Kynetx::Expressions::typed_value(\@elements);
}

sub make_source {
    my ($obj) = @_;
    my $logger = get_logger();
    my @sources;
    if ($obj->{'type'} eq 'str') {
        push(@sources,"text" => $obj->{'val'});
    } elsif ($obj->{'type'} eq 'array') {
        foreach my $element (@{$obj->{'val'}}) {
            push(@sources,"text" => \$element);
        }
    }
    return \@sources;
}

sub make_selector {
    my ($rand,$rule_env, $rule_name,$req_info, $session) = @_;
    my @selector;
    my $logger = get_logger();
    if ($rand->{'type'} eq 'str') {
        push (@selector, $rand->{'val'});
    } elsif ($rand->{'type'} eq 'array') {
        foreach my $element (@{$rand->{'val'}}) {
            my $obj =
                Kynetx::Expressions::eval_expr($element, $rule_env, $rule_name,$req_info, $session);
            my $clean = $obj->{'val'};
            push(@selector,$clean);
        }

    }
    return join(",",@selector);
}

1;
