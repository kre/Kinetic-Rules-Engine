package Kynetx::Predicates::OData;

# file: Kynetx/Predicates/OData.pm
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

use lib qw(../../);

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;

use Kynetx::Util qw(
    end_slash
); 
use Kynetx::Json qw(
  jsonToAst_w
  get_obj
);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $ODATA_OPERATORS = [
                         '$top',    '$skip',   '$expand', '$filter',
                         '$format', '$select', '$inlinecount', '$orderby'
];

our $SO_OPERATORS = [ '$expand', '$format', '$inlinecount' ];

use constant SO_Q_COL => 2;
use constant RP_COL   => 1;
use constant OP_COL   => 2;

my %predicates = (
    'entity_sets' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        my $url    = build( 'service_document', $args );
        my $resp   = request($url);
        if ( defined $resp ) {
            my $sets = get_obj( jsonToAst_w($resp->content), qr/\EntitySets/ );
            return $sets
        }
    },
    'metadata' => sub {

        # metadata only returns xml data
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        my $url    = build( 'metadata', $args );
        my $resp   = request($url);
        if ( defined $resp ) {
            my $obj = Kynetx::Json::xmlToJson( $resp->content );
            return $obj;

            #            For now, I don't have a good simplification to justify
            #            further processing of the metadata
            #            Kynetx::Json::collapse($obj);
            #            $logger->debug( "ES: ", sub { Dumper($obj) } );
            #            my $meta_objs = get_metadata_args($args);
            #            if ( defined $meta_objs ) {
            #                $logger->debug( "Get meta elements: ",
            #                                sub { Dumper($meta_objs) } );
            #                my @m_array;
            #                foreach my $key (@$meta_objs) {
            #                    my $subo = get_obj( $obj, qr/$key/ );
            #                    if ( defined $subo ) {
            #                        $logger->debug( "metadata match",
            #                                        sub { Dumper($subo) } );
            #                        push( @m_array, \$subo );
            #                    }
            #                }
            #                return \@m_array;
            #            } else {
            #                return $obj;
            #            }
        }

    },
    'service_operation' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        $logger->debug( "ServiceOperation args: ", sub { Dumper($args) } );
        my $url = build( 'service_operation', $args );
        my $resp = request($url);
        my $result;
        if ( defined $resp ) {
            $result = jsonToAst_w( $resp->content );
            $logger->trace( "ES: ", sub { Dumper($result) } );
        }
        return $result;
    },
    'get' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        $logger->debug( "args: ", sub { Dumper($args) } );
        my $url = build( 'get', $args );
        my $resp = request($url);
        my $result;
        if ( defined $resp ) {
            $result = jsonToAst_w( $resp->content );
            $logger->trace("ES: ", sub { Dumper($result) } );
        }
        return $result;

      }

);

sub get_predicates {
    return \%predicates;
}

sub eval_odata {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $retval;
    if ( $function eq 'channel' ) {
        $retval = channel_elements($args);
    } elsif ( $function eq 'item' ) {
        $retval = item_elements($args);
    } else {
        $logger->warn( "No definition for function: ", $function );
    }

    return $retval;
}

sub build {
    my ( $target, $args ) = @_;
    my $logger = get_logger();
    my $url;

    $url = get_service_root($args);
    if ( $target eq 'metadata' ) {
        $url = Kynetx::Util::end_slash($url) . '$metadata';
    } elsif ( $target eq 'service_operation' ) {
        $url = Kynetx::Util::end_slash($url);
        $url .= get_function_name($args);
        my @parms = get_function_query_parameters($args);
        $logger->debug( "Parms: ", sub { Dumper(@parms) } );
        $url .= '?' . join( '&', @parms );
    } elsif ( $target eq 'get' ) {
        $url = Kynetx::Util::end_slash($url);
        $url .= get_resource_path($args) || '';
        $url .= get_operations($args) || '';
    }

    $logger->debug( "OData host: ", $url );
    return $url;
}

sub get_resource_path {
    my ($args) = @_;
    my $logger = get_logger();
    $logger->trace( "resource path args: ", sub { Dumper($args) } );
    my $rpath_ref = $args->[RP_COL];
    if ( ref $rpath_ref eq '' ) {
        return $rpath_ref;
    } elsif ( ref $rpath_ref eq 'ARRAY' ) {

        #if the first value is a scalar the only other option is $count
        my $collection = $rpath_ref->[0];
        if ( ref $collection eq '' ) {
            if ( defined $rpath_ref->[1] && $rpath_ref->[1] eq '$count' ) {
                return $collection . '/$count';
            } else {
                return $collection;
            }
        } else {
            my @nav_path;
            foreach my $element (@$rpath_ref) {
                if ( ref $element eq 'HASH' ) {
                    my $temp = get_nav_prop_hash($element);
                    if ( defined $temp ) {
                        push( @nav_path, $temp );
                    }
                } elsif ( ref $element eq '' ) {
                    push( @nav_path, $element );
                }

            }
            return join( '/', @nav_path );
        }
    } elsif ( ref $rpath_ref eq 'HASH' ) {
        my $temp = get_nav_prop_hash($rpath_ref);
        if ( defined $temp ) {
            return ($temp);
        }
    }
}

sub get_nav_prop_hash {
    my ($element) = @_;
    my ( $name, $key ) = %$element;
    if ( $name && $key ) {
        my $nav_prop = $name . '(' . $key . ')';
        return $nav_prop;
    } else {
        return undef;
    }
}

sub get_metadata_args {
    my ($args) = @_;
    my $logger = get_logger();
    if ( ref $args->[1] eq 'ARRAY' ) {
        return $args->[1];
    }
    if ( defined $args->[1] && ref $args->[1] ne 'HASH' ) {
        return [ $args->[1] ];
    }
    return undef;
}

sub get_function_name {
    my ($args) = @_;
    if ( ref $args->[1] eq '' ) {
        return $args->[1];
    }
    return undef;
}

sub get_operations {
    my ($args) = @_;
    my $logger = get_logger();
    $logger->trace( "operations args: ", sub { Dumper($args) } );
    my $operations = $args->[OP_COL];
    my @o_arry;
    if (ref $operations eq 'HASH') {
        foreach my $key (keys %$operations) {
            my $op = get_operation_parameter($key,$operations->{$key},$ODATA_OPERATORS);
            if (defined $op) {
                push(@o_arry,$op);
            }
        }
        return '?'.join('&',@o_arry);
    } elsif (ref $operations eq 'ARRAY') {
        
    } elsif ($operations) {
        return '?' . $operations;
    }
}

sub get_function_query_parameters {
    my ($args) = @_;
    my $logger = get_logger();
    my @q_arry;
    my @o_arry;
    my $t = $args->[SO_Q_COL];
    if ( defined $t && ref $t eq 'HASH' ) {
        foreach my $key ( keys %$t ) {
            my $value = $t->{$key};
            if ( $key =~ m/^\$\w+/ ) {
                my $op = get_operation_parameter( $key, $value, $SO_OPERATORS );
                if ( defined $op ) {
                    push( @o_arry, $op );
                }
            } else {
                if ( ref $value eq 'ARRAY' ) {
                    $value = join( ',', @$value );
                } elsif ( ref $value eq '' ) {

                } else {
                    next;
                }
                push( @q_arry, $key . '=' . $value );
            }
        }
        push( @q_arry, @o_arry );
        return @q_arry;
    } else {
        return undef;
    }
}



sub get_operation_parameter {
    my ( $key, $value, $allowed ) = @_;
    my $logger = get_logger();
    $logger->trace( "operation args: ", $key," => ",sub { Dumper($value) } );
    my $found;
    map { $found->{$_} = 1 } @$allowed;
    if ( $found->{$key} ) {

        if ( ref $value eq '' ) {
            return $key . '=' . $value;
        } elsif ( ref $value eq 'ARRAY' ) {
            return $key . '=' . join( ',', @$value );
        }
    }
    return undef;
}

# first argument should always be s.r.
sub get_service_root {
    my ($args) = @_;
    my $service_root = $args->[0];
    return $service_root;
}

sub request {
    my ($url) = @_;
    my $logger = get_logger();
    my $hreq = HTTP::Request->new( GET => $url );
    $url =~ m/(\$metadata|\$count|\$value)$/;
    if ( !$1 ) {
        $hreq->header( 'accept' => 'application/json' );
    } elsif ( $1 eq '$count' || $1 eq '$value') {
        $hreq->header( 'accept' => 'text/plain' );
    } elsif ($1 eq '$metadata'){
        $hreq->header( 'accept' => 'application/xml' );
    } else {
        $hreq->header( 'accept' => 'application/json');
    }
    my $ua    = LWP::UserAgent->new;
    my $resp  = $ua->simple_request($hreq);
    my $count = 1;
    while ( $resp->is_redirect ) {
        $logger->trace( "Redirect ($count): ", $resp->header("location") );
        my $r_url = URI->new( $resp->header("location") );
        $hreq->uri($r_url);
        $resp = $ua->simple_request($hreq);
    }

    #$logger->debug("Request returns: ", sub {Dumper($resp)});
    return $resp;
}
1;
