package Kynetx::Json;

# file: Kynetx/Json.pm
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
use utf8;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;
use XML::XML2JSON;
use Data::Dumper;

use Kynetx::Parser; # qw/:all/;
use Kynetx::PrettyPrinter; # qw/:all/;
use Kynetx::Errors ;
use YAML::XS;

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
          perlToJson
          get_items
          deserialize_regexp_objects
          serialize_regexp_objects
          $REGEXP_TAG
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our $REGEXP_TAG = "__regexp__";

sub krlToJson {
    my ($krl) = @_;

    my $tree = Kynetx::Parser::parse_ruleset($krl);
    return JSON::XS::->new->utf8(1)->pretty(1)->encode($tree);
    #return JSON::XS::->new->pretty(1)->encode($tree);

}

sub jsonToKrl {
    my ($json) = @_;

    my $tree = JSON::XS::->new->utf8(1)->pretty(1)->decode($json);
    #my $tree = JSON::XS::->new->pretty(1)->decode($json);
    return Kynetx::PrettyPrinter::pp($tree);

}

sub jsonToRuleBody {
    my ($json) = @_;

    #my $tree = JSON::XS::->new->utf8(1)->pretty(1)->decode($json);
    my $tree = JSON::XS::->new->pretty(1)->decode($json);
    return Kynetx::PrettyPrinter::pp_rule_body( $tree, 0 );

}

# a renaming of encode_json for Abstract Syntax Trees
sub astToJson {
    my ($ast) = @_;

    #return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(1)->encode($ast);
    return JSON::XS::->new->convert_blessed(1)->pretty(1)->encode($ast);

}

sub jsonToAst {
    my ($json) = @_;
	my $logger = get_logger();
	#$logger->debug("Original string: (", ref $json,") ", $json);
    #return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(1)->decode($json);
    return JSON::XS::->new->convert_blessed(1)->pretty(1)->decode($json);

}

# Wrap any conversion errors and just return content
sub jsonToAst_w {
    my ($json)=@_;
    my $logger = get_logger();
    my $pstruct;
    eval {
        #$pstruct = JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(1)->decode($json);
        $pstruct = JSON::XS::->new->convert_blessed(1)->allow_nonref->pretty(1)->decode($json);
    };
#    if ($@ && not defined $pstruct) { # $pstruct is always defined (with a string)
    if ($@) {
      # Kynetx::Errors::raise_error($req_info, 'warn',
      # 				  "[json] conversion error: $@",
      # 				  {'rule_name' => $rule_name,
      # 				   'genus' => 'data',
      # 				   'species' => 'conversion failed'
      # 				  }
      # 				 );

        $logger->debug("####JSON conversion error: ",$@);
        $logger->trace("Source: \n##################################################\n$json");
        return {'error' => [$json]};
    } else {
        return $pstruct;
    }
}

sub perlToJson {
    my ($log_val, $pretty_print) = @_;
    $pretty_print ||= 0; # default to no pretty print
    return ref $log_val eq 'HASH' || 
           ref $log_val eq 'ARRAY' ? JSON::XS::->new->convert_blessed(1)->pretty($pretty_print)->encode($log_val) 
                                   : $log_val
}

sub serialize_regexp_objects {
    my ( $obj ) = @_;
    my $logger = get_logger();
    my $ret_val;
    if ( ref $obj eq 'HASH' ) {
        foreach my $key ( keys %$obj ) {
            my $value = $obj->{$key};
            if (ref $value eq "Regexp" ) {
                $obj->{$key} = {$REGEXP_TAG => YAML::XS::Dump $value};
            } else {
                serialize_regexp_objects( $obj->{$key} );
            }

        }
    } elsif ( ref $obj eq 'ARRAY' ) {
        foreach my $element (@$obj) {
            serialize_regexp_objects( $element );
        }
    }

}

sub deserialize_regexp_objects {
    my ( $obj ) = @_;
    my $logger = get_logger();
    my $ret_val;
    if ( ref $obj eq 'HASH' ) {
        foreach my $key ( keys %$obj ) {
            my $value = $obj->{$key};
            if (ref $value eq "HASH" && $value->{$REGEXP_TAG}) {
                my $regexp =  YAML::XS::Load $value->{$REGEXP_TAG};
                $obj->{$key} = $regexp;
            } else {
                deserialize_regexp_objects( $obj->{$key} );
            }
        }
    } elsif ( ref $obj eq 'ARRAY' ) {
        foreach my $element (@$obj) {
            deserialize_regexp_objects( $element );
        }
    }
}

sub xmlToJson {
    my ($xmlsource) = @_;
    my $logger = get_logger();
    #$logger->debug( "XML Source: ", $xmlsource );
    my $XML2JSON = XML::XML2JSON->new( module => 'JSON::XS', pretty => 1 );
    my $obj = $XML2JSON->xml2obj($xmlsource);
    $XML2JSON->sanitize($obj);
    my $json = $XML2JSON->obj2json($obj);
    #$logger->debug( "XML2JSON: ", sub { Dumper($json) } );
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
            return Kynetx::Errors::merror("Path element: " . join("->",@trail)." not found");
        }
    }
    return $result;
}

# initial call to get_items does not require $collection
sub get_items {
    my ($obj,$regexp,$collection) = @_;
    my $logger = get_logger();
    unless (ref $regexp eq 'Regexp') {
        $regexp = qr($regexp);
        unless (ref $regexp eq 'Regexp') {
            return (Kynetx::Errors::merror("Regexp or string required for get_items"));
        }
    }
    if (ref $obj eq 'HASH') {
        foreach my $key (%$obj) {
            if ($key =~ $regexp) {
                #$logger->debug("Key: ",sub {Dumper($key)});
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
            $logger->trace("  key: ",$key);
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
