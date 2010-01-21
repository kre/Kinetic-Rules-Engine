package Kynetx::Json;
# file: Kynetx/Json.pm
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
use utf8;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
krlToJson
jsonToKrl
jsonToRuleBody
astToJson
jsonToAst
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub krlToJson {
    my($krl) = @_;

    my $tree = parse_ruleset($krl);
    return encode_json($tree);

}

sub jsonToKrl {
    my($json) = @_;

    my $tree = decode_json($json);
    return pp($tree);


}

sub jsonToRuleBody {
    my($json) = @_;

    my $tree = decode_json($json);
    return pp_rule_body($tree,0);


}


# a renaming of encode_json for Abstract Syntax Trees
sub astToJson {
    my($ast) = @_;

    return encode_json($ast);

}

sub jsonToAst {
    my($json) = @_;

    return decode_json($json);

}



1;
