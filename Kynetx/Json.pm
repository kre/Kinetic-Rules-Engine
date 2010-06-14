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
use XML::XML2JSON;
use Data::Dumper;

use Kynetx::Parser; # qw/:all/;
use Kynetx::PrettyPrinter; # qw/:all/;
use Kynetx::Util qw ( merror );

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          krlToJson
          jsonToKrl
          jsonToRuleBody
          astToJson
          jsonToAst
          jsonToAst_w
          get_items
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

sub krlToJson {
    my ($krl) = @_;

    my $tree = Kynetx::Parser::parse_ruleset($krl);
    return JSON::XS::->new->utf8(1)->pretty(1)->encode($tree);

}

sub jsonToKrl {
    my ($json) = @_;

    my $tree = JSON::XS::->new->utf8(1)->pretty(1)->decode($json);
    return Kynetx::PrettyPrinter::pp($tree);

}

sub jsonToRuleBody {
    my ($json) = @_;

    my $tree = JSON::XS::->new->utf8(1)->pretty(1)->decode($json);
    return Kynetx::PrettyPrinter::pp_rule_body( $tree, 0 );

}

# a renaming of encode_json for Abstract Syntax Trees
sub astToJson {
    my ($ast) = @_;

    return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(1)->encode($ast);

}

sub jsonToAst {
    my ($json) = @_;

    return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(1)->decode($json);

}

# Wrap any conversion errors and just return content
sub jsonToAst_w {
    my ($json)=@_;
    my $logger = get_logger();
    my $pstruct;
    eval {
        $pstruct = jsonToAst($json);
    };
    if ($@) {
        $logger->debug(
                     "Invalid JSON format => parse result as string error(",
                     sub { Dumper(@_) });
        return $json
    } else {
        return $pstruct;
    }
}

sub xmlToJson {
    my ($xmlsource) = @_;
    my $logger = get_logger();
    #$logger->trace( "XML Source: ", $xmlsource );
    my $XML2JSON = XML::XML2JSON->new( module => 'JSON::XS', pretty => 1 );
    my $obj = $XML2JSON->xml2obj($xmlsource);
    $XML2JSON->sanitize($obj);
    my $json = $XML2JSON->obj2json($obj);
    #$logger->trace( "XML2JSON: ", sub { Dumper($json) } );
    return $obj;
}

# special convenience function to trim the clutter that is
# introduced when you convert XML to JSON
sub collapse {
    my ($obj) = @_;
    my $logger = get_logger();
    if (ref $obj eq 'HASH') {
        my $count = int(keys %$obj);
        foreach my $key (keys %$obj) {
            my $outstring = "$count $key ";
            my $value = $obj->{$key};
            if ($key =~ m/^\@(.+)/) {
                $outstring .= "<ugly>";
                delete $obj->{$key};
                $obj->{$1} = $value;
            }
            my $skip = lookahead($value);
            $outstring .= ref $value;
            if ($skip)   {
                $obj->{$key}=$skip;
            }  else {
                collapse($value);
            }
        }
    } elsif (ref $obj eq 'ARRAY') {
        foreach my $element (@$obj) {
            my $skip = lookahead($element);
            if ($skip) {
                $element = $skip;
            }
            collapse($element);
        }

    } else {
        return $obj;
    }
}

sub lookahead {
    my ($obj) = @_;
    return '' unless (ref $obj eq 'HASH');
    my ($k,$v) = each %$obj;
    return '' unless (defined $k);
    if ($k eq '$t') {
        return $v;
    } else {
        return '';
    }
}

sub get_path {
    my ($obj,$str_path) =@_;
    my $logger = get_logger();
    my @path_elements = split(/\./,$str_path);
    my $result = $obj;
    my @trail;
    foreach my $element (@path_elements) {
        push(@trail,$element);
        $result = get_items($result,$element);
        if (! $result) {
            return merror("Path element: " . join("->",@trail)." not found");
        }
    }
    return $result;
}

sub get_items {
    my ($obj,$regexp,$collection) = @_;
    my $logger = get_logger();
    unless (ref $regexp eq 'Regexp') {
        $regexp = qr($regexp);
        unless (ref $regexp eq 'Regexp') {
            return (merror("Regexp or string required for get_items"));
        }
    }
    if (ref $obj eq 'HASH') {
        foreach my $key (%$obj) {
            if ($key =~ $regexp) {
                $logger->trace("Key: ",sub {Dumper($key)});
                my $match = $obj->{$key};
                if ($match) {
                    push(@$collection,$match);
                }
            } else {
                $collection = get_items($obj->{$key},$regexp,$collection);
            }
        }
    } elsif (ref $obj eq 'ARRAY') {
        foreach my $element (@$obj) {
            $collection = get_items($element,$regexp,$collection);
        }
    }
    return $collection;
}

sub get_obj {
    my ( $obj, $regexp ) = @_;
    my $logger = get_logger();
    my $ret_val;
    if ( ref $obj eq 'HASH' ) {
        foreach my $key ( keys %$obj ) {
            $logger->debug("  key: ",$key);
            if ( $key =~ $regexp ) {
                return $obj->{$key};
            } else {
                $ret_val = get_obj( $obj->{$key}, $regexp );
                if ($ret_val) {
                    return $ret_val;
                }
            }
        }
    } elsif ( ref $obj eq 'ARRAY' ) {
        foreach my $element (@$obj) {
            $ret_val = get_obj( $element, $regexp );
            if ($ret_val) {
                return $ret_val;
            }
        }
    }

}

1;
