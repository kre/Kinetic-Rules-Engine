#!/usr/bin/perl -w

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
use lib qw(/web/lib/perl);
use strict;


use Test::More;
use Test::Deep;
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


use Kynetx::Test qw/:all/;
use Kynetx::JParser qw/:all/;
use Kynetx::OParser qw(:all);
use Kynetx::Configure;
use Kynetx::Json qw(:all);

Kynetx::Configure::configure();
my $logger = get_logger();

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/*.krl>;

# all the files in the rules repository
#my @krl_files = @ARGV ? @ARGV : </web/work/krl.kobj.net/rules/client/*.krl>;

# testing some...
# my @krl_files = <new/ineq[0-0].krl>;
#my @krl_files = <new/*.krl>;
my $debug = 0;

my @skips = qw(
    data/exprs0.krl
    data/regexp0.krl
    data/regexp1.krl
    data/regexp2.krl
    data/regexp3.krl
    data/regexp4.krl
    data/regexp5.krl
    data/regexp6.krl
    data/regexp7.krl
    data/regexp8.krl
    data/regexp9.krl
);

my $skip_list;
map {$skip_list->{$_} = 1} @skips;

$logger->debug("Skips: ", sub {Dumper($skip_list)});

my $num_tests = $#krl_files+1;
my $jparser = Kynetx::JParser::get_antlr_parser();
foreach my $f (@krl_files) {
    my ($fl,$krl_text) = getkrl($f);
    if ($debug) {
        diag $f;
    }
    if ($skip_list->{$f}) {
        diag "Skipping $f";
        $num_tests--;
        next;
    }
    my $ptree = $jparser->ruleset($krl_text);
    my $ast = Kynetx::Json::jsonToAst_w($ptree);
    my $o_ast = Kynetx::OParser::parse_ruleset($krl_text);
    trim_line_numbers($o_ast);
    my $result = cmp_deeply($ast,$o_ast,$fl);
    if (! $result) {
        $logger->debug("JSON: ", $ptree);
        $logger->debug("Antler AST: ", sub {Dumper($ast)});
        $logger->debug("Old AST: ", sub {Dumper($o_ast)});
        #die ($f);
    }
}
plan tests => $num_tests;


# Remove the line numbering tags from the old parser
sub trim_line_numbers{
    my ($ast) = @_;
    delete $ast->{'dispatch_start_col'};
    delete $ast->{'dispatch_start_line'};
    delete $ast->{'global_start_col'};
    delete $ast->{'global_start_line'};
    delete $ast->{'meta_start_col'};
    delete $ast->{'meta_start_line'};

    # Global string cheat
    foreach my $global (@{$ast->{'global'}}) {
        if ($global->{'type'} eq "css" ) {
            $global->{'content'} = "\n" . $global->{'content'};
        } elsif ($global->{'emit'}) {
            $global->{'emit'} = "\n" .$global->{'emit'};
        } elsif ($global->{'type'} eq "here_doc") {
            $global->{'rhs'} = "\n" . $global->{'rhs'};
        }
    }
    if ($ast->{'meta'}) {
        delete $ast->{'meta'}->{'meta_start_line'};
        delete $ast->{'meta'}->{'meta_start_col'};
        if ($ast->{'meta'}->{'description'}) {
            $ast->{'meta'}->{'description'} = "\n".$ast->{'meta'}->{'description'};
        }
    }

    if ($ast->{'dispatch'}) {
        foreach my $dispatch (@{$ast->{'dispatch'}}) {
            #delete $dispatch->{'ruleset_id'} unless ($dispatch->{'ruleset_id'});
        }
    }

    # Clean the individual rules
    foreach my $rule (@{$ast->{'rules'}}) {
        delete $rule->{'start_col'};
        delete $rule->{'start_line'};
        #delete $rule->{'post'} unless (defined $rule->{'post'});

        # Clean the actions
        foreach my $action (@{$rule->{'actions'}}) {
            #delete $action->{'label'} unless (defined $action->{'label'});
            #delete $action->{'action'}->{'vars'} unless (defined $action->{'action'}->{'vars'});
            #delete $action->{'action'} unless (keys %{$action->{'action'}});
            if ($action->{'emit'}) {
                $action->{'emit'} = "\n" . $action->{'emit'};
            }
        }

        # Trim undef callbacks
        #delete $rule->{'callbacks'}->{'success'} unless (defined $rule->{'callbacks'}->{'success'});
        #delete $rule->{'callbacks'}->{'failure'} unless (defined $rule->{'callbacks'}->{'failure'});

        #  Modify callback block for empties
        #$rule->{'callbacks'} = undef unless (keys %{$rule->{'callbacks'}});

        #  Modify pre block for empties
        foreach my $expr (@{$rule->{'pre'}}) {
            if ($expr->{"type"} eq "here_doc") {
                my $rhs = $expr->{"rhs"};
                $expr->{"rhs"} = "\n" . $rhs;
            }
        }
        #delete $rule->{'pre'} unless ($rule->{'pre'});


    }

}

1;


