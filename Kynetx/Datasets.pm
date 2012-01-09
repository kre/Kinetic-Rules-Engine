package Kynetx::Datasets;

# file: Kynetx/Datasets.pm
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
use warnings;
use utf8;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;
use Data::Dumper;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          cache_dataset_for
          get_dataset
          mk_dataset_js
          get_datasource
          global_dataset
          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

#use Kynetx::JavaScript qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Rids qw/:all/;

our $AUTOLOAD;

my %fields = (
               source     => undef,
               name       => undef,
               type       => undef,
               sourcedata => undef,
               datatype   => undef,
               cachable   => 10 * 60,                  # Default minimum
               json       => JSON::XS->new,
);

sub new {
    my $class  = shift;
    my $logger = get_logger();
    my $self   = { %fields, };
    bless( $self, $class );
    my ($var_hash) = @_;
    if ( defined $var_hash ) {
        if ( ref $var_hash eq 'HASH' ) {
            $logger->trace( "data hash: ", sub { Dumper($var_hash) });
            foreach my $varkey ( keys %$var_hash ) {
                $logger->trace( "var: ", $varkey, "->", $var_hash->{$varkey} );
                if ( exists $self->{$varkey} ) {
                    if ( $varkey eq 'cachable' ) {
                        $self->set_cache( $var_hash->{$varkey} );
                    } else {
                        $self->{$varkey} = $var_hash->{$varkey};
                    }
                }
            }
        } else {
            die "Initialization failed. Args not passed as a hash";
        }
    }

    return $self;
}

sub AUTOLOAD {
    my $self   = shift;
    my $logger = get_logger();
    my $type   = ref($self)
      or die "($AUTOLOAD): $self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    if ( $name eq 'datasource' ) {
        $logger->trace( "Autoload: " . sub { Dumper($self) } );
    }
    unless ( exists $self->{$name} ) {
        $logger->trace("$name not permitted in class $type");
        return;
    }

    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

sub DESTROY { }

sub set_cache {
    my $self = shift;
    my ($cachable) = @_;

    #  Even if the customer does not ask for a cache, we will cache it
    #  for 10 minutes
    my $minimum   = 10 * 60;
    my $cachetime = $minimum;
    if ( defined $cachable ) {
        if ( ref $cachable eq 'HASH' ) {
            my $period = $cachable->{'period'};
            my $num    = $cachable->{'value'};
            if ( $num =~ /^\d+$/ ) {
                if ( $period eq 'years' ) {
                    $cachetime = $num * 60 * 60 * 24 * 365;
                } elsif ( $period eq 'months' ) {
                    $cachetime = $num * 60 * 60 * 24 * 30;
                } elsif ( $period eq 'weeks' ) {
                    $cachetime = $num * 60 * 60 * 24 * 7;
                } elsif ( $period eq 'days' ) {
                    $cachetime = $num * 60 * 60 * 24;
                } elsif ( $period eq 'hours' ) {
                    $cachetime = $num * 60 * 60;
                } elsif ( $period eq 'minutes' ) {
                    $cachetime = $num * 60;
                } elsif ( $period eq 'seconds' ) {
                    $cachetime = $num;
                }

                #if ( $cachetime < $minimum ) {
                #   $cachetime = $minimum;
                #}
            }
        } elsif ( $cachable > 0 ) {

            # cachable is either a flag or a hash ref to a period/number
            $cachetime = Kynetx::Configure::get_config('CACHEABLE_THRESHOLD');

        } else {
            $cachetime = $minimum;
        }

    }
    return $self->cachable($cachetime);
}

sub is_global {
    my $self = shift;

    if ( $self->cachable >=
         Kynetx::Configure::get_config('CACHEABLE_THRESHOLD') )
    {
        return 1;
    } else {
        return 0;
    }

}

sub _load_dataset {
    my $self        = shift;
    my ($req_info)  = @_;
    my $source_name = $self->source;
    my $logger      = get_logger();

    # If it is not formatted like an URL request, assume it is a file
    if ( $source_name =~ m#^(http|https)://# ) {

        # URL branch
        $self->sourcedata(
             Kynetx::Memcached::get_remote_data( $source_name, $self->cachable )
        );
    } else {
        $logger->trace( "[Dataset] Get local file => ", $source_name );

        # FILE branch
        # build the absolute path to the file
        $source_name = join(
                             "/",
                             (
                                Kynetx::Configure::get_config('DATA_ROOT'),
                                get_rid($req_info->{'rid'}), $source_name
                             )
        );
        $self->source($source_name);
        $self->sourcedata( Kynetx::Memcached::get_cached_file($source_name) );
    }

    #$logger->debug("[_load_dataset] source =>",$self->sourcedata);

}

sub _load_datasource {
    my $self = shift;
    my ( $req_info, $args ) = @_;

    my $source_url = $self->source;
    my $logger     = get_logger();

    if ( ref $args->[0] eq 'HASH' ) {

        # Datasources should be RESTful GETS
        if ( $source_url =~ m/\?/ ) {
            $source_url .= '&';
        } else {
            $source_url .= '?';
        }

        my @params;
        for my $k ( keys %{ $args->[0] } ) {
            push( @params, $k . "=" . $args->[0]->{$k} );
        }

        # Perl doesn't guarantee hash order, sort keys
        # so that data is cached efficiently
        $source_url .= join( '&', ( sort @params ) );
    } else {
        $logger->trace( "[Datasets] datasource args: ", sub { Dumper $args });
        if (defined $args->[0]) {
        	$source_url .= $args->[0];
        }
    }
    $self->source($source_url);
    $self->sourcedata(
           Kynetx::Memcached::get_remote_data( $source_url, $self->cachable ) );

}

sub load {
    my $self = shift;
    my ( $req_info, $args ) = @_;
    if ( $self->type eq 'dataset' ) {
        $self->_load_dataset($req_info);
    } elsif ( $self->type eq 'datasource' ) {
        $self->_load_datasource( $req_info, $args );
    }

}

sub unmarshal {
    my $self   = shift;
    my $logger = get_logger();
    if ( !defined $self->sourcedata or $self->sourcedata eq '' ) {
      # Kynetx::Errors::raise_error($req_info, $session,'warn',
      # 				  "[datasets] No source data loaded"
      # 				  {'rule_name' => $rule_name,
      # 				   'genus' => 'data',
      # 				   'species' => 'source unavailable'
      # 				  }
      # 				 );

      $logger->warn("[datasets] No source data loaded");
    }
    if ( defined $self->datatype ) {
        $logger->trace( "datatype: ", $self->datatype );
        my $switch = $self->datatype;
        if ( $switch eq 'JSON' ) {
            $logger->debug(   "[Datasets] Parse "
                            . $self->type . ":"
                            . $self->name
                            . " as JSON" );
            $self->_unmarshal_json();
        } elsif ( $switch eq 'XML' ) {
            $logger->debug(   "[Datasets] Parse "
                            . $self->type . ":"
                            . $self->name
                            . " as XML" );
            $self->_unmarshal_xml();
        } elsif ( $switch eq 'RSS' ) {
            $logger->debug(   "[Datasets] Parse "
                            . $self->type . ":"
                            . $self->name
                            . " as RSS" );
            $self->_unmarshal_xml();
        } elsif ( $switch eq 'HTML' ) {
            $logger->debug(   "[Datasets] Parse "
                            . $self->type . ":"
                            . $self->name
                            . " as HTML" );
            $self->_unmarshal_string();
        } else {
            $logger->debug(   "[Datasets] Parse "
                            . $self->type . ":"
                            . $self->name
                            . " as STRING" );
            $self->_unmarshal_string();
        }
    } else {
        $self->_unmarshal_json();
    }
}

sub make_javascript {
    my $self   = shift;
    my ($dev)  = @_;
    my $logger = get_logger();
    my $js     = "KOBJ['data']['" . $self->name . "'] = ";

    # if the source data was not convertable into a perl/JSON representation
    # $json will be undefined and treat the source data as a string
    if ( !defined $self->json ) {
            $js .= Kynetx::JavaScript::mk_js_str( $self->sourcedata );
    } else {
            #$js .= JSON::XS::->new->utf8(1)->pretty(1)->encode( $self->json );
            $js .= JSON::XS::->new->pretty(1)->encode( $self->json );
    }
    $js .= ";\n";
    $logger->trace("UTF-8 flag: ", utf8::is_utf8($js));
    return $js;
}

sub _unmarshal_string {
    my $self = shift;
    $self->json(undef);
    if ( defined $self->sourcedata ) {
        my $stringsource = $self->sourcedata;
        $stringsource =~ s/[\n|\r]//g;
        $self->sourcedata($stringsource);
    } else {
        $self->sourcedata('');
    }
}

sub _unmarshal_xml {
    my $self   = shift;
    my $logger = get_logger();
    my $perl;
    my $json;
    #my $XML2JSON = XML::XML2JSON->new( module => 'JSON::XS', pretty => 0 );
    #$perl = $XML2JSON->xml2obj( $self->sourcedata );
    $perl = Kynetx::Json::xmlToJson($self->sourcedata);

    #$logger->trace("Perl (JSON) Obj: " , Dumper($perl));
    $self->json($perl);
}

sub _unmarshal_json {
    my $self   = shift;
    my $logger = get_logger();
    my $json;

    # catch any errors thrown by JSON::XS
    eval {
        $json =
          #JSON::XS::->new->utf8(1)->pretty(1)->decode( $self->sourcedata );
          JSON::XS::->new->pretty(1)->decode( $self->sourcedata );
    };
    if ($@) {
        $self->json(undef);
        $logger->debug(
                     "[Datasets] Invalid JSON format => parse result as string",
                     sub { Dumper(@_) } );
    } else {

        # JSON string converted to perl hash
        $self->json($json);
        $logger->trace( "[Datasets] ", sub { Dumper( $self->json ) });
    }

}

sub cache_dataset_for {
    my ($dsr)  = @_;
    my $ds     = new Kynetx::Datasets $dsr;
    my $logger = get_logger();
    $logger->trace( "[cache dataset for] ", $ds->cachable );
    return $ds->cachable;
}

sub get_dataset {
    my ( $dsr, $req_info ) = @_;
    my $result;
    my $logger = get_logger();
    my $ds     = new Kynetx::Datasets $dsr;
    $ds->load($req_info);
    $ds->unmarshal();
    $result = $ds->sourcedata;
    $logger->trace( "[get dataset] ", $result );
    return $result;

}

sub mk_dataset_js {
    my ( $g, $req_info, $rule_env ) = @_;
    my ( $perlset, $js );
    my $logger = get_logger();
    my $ds     = new Kynetx::Datasets $g;
    $logger->trace( "[mk dataset js] ", $js );
    $ds->load($req_info);
    $ds->unmarshal();
    $js = $ds->make_javascript();

    if ( defined $ds->json ) {
        $perlset = $ds->json;
    } else {
        $perlset = $ds->sourcedata;
    }
    $logger->trace( "[mk dataset js] ", $js );
    return ( $js, $ds->name, $perlset );

}

sub get_datasource {
    my ( $rule_env, $args, $function ) = @_;
    my $req_info;
    my $logger = get_logger();
    $logger->trace( "[get datasource] re: ",  sub {Dumper $rule_env});
    $logger->trace( "[get datasource] arg: ", sub {Dumper $args});
    $logger->trace( "[get datasource] fx: ",  sub {Dumper $function});
    $logger->trace( "[get datasource] ruleset:",
                    sub { Dumper( $rule_env->{ 'datasource:' . $function } ) });
    my $ds = new Kynetx::Datasets lookup_rule_env( 'datasource:' . $function,
                                                   $rule_env );
    $logger->trace( "[get datasource] new: ", sub {Dumper $ds});
    $ds->load( $req_info, $args );
    $logger->trace( "[get datasource] load: ", sub {Dumper $ds});
    $ds->unmarshal();

    if ( defined $ds->json ) {
        return $ds->json;
    } else {
        return $ds->sourcedata;
    }

}

sub global_dataset {
    my ($dsr)  = @_;
    my $logger = get_logger();
    my $ds     = new Kynetx::Datasets $dsr;
    $logger->trace( "[global dataset] ", $ds->is_global() );
    return $ds->is_global();
}

1;
