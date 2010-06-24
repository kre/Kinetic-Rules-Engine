package Kynetx::Operators::Query;
# file: Kynetx/Operators/Query.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#
use strict;
use warnings;

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
