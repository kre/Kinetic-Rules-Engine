package Kynetx::Predicates::Amazon::ItemSearch;

# file: Kynetx/Predicates/Amazon/ItemSearch.pm
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

use Log::Log4perl qw(get_logger :levels);

use Apache2::Const;
use YAML::XS;
use URI::Escape qw(uri_escape_utf8);

use Data::Dumper;

use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Errors;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter Kynetx::Predicates::Amazon);

# put exported names inside the "qw" 
our %EXPORT_TAGS = (
    all => [
        qw(
        build
        get_search_index
        get_item_search_response_groups
        get_search_index_parameters
        )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
Kynetx::Configure::configure();

use constant DEFAULT_INDEX => 'All';
use constant DEFAULT_LOCALE =>  'us';
use constant DEFAULT_RESPONSE_GROUP => 'Small';

sub validate_response_group {
    my ($rg) = @_;
    my $response_group = Kynetx::Configure::get_config('RESPONSE_GROUP','AMAZON');
    my $rg_set = $response_group->{'item_search'};
    foreach my $element (@$rg_set) {
       if (uc($element) eq uc($rg)) {
           return $element;
       }
    }
    return 0;
}

sub get_response_groups {
    my ($args) = @_;
    my $logger = get_logger();
    my $group_ = $args->{'response_group'};
    if (defined $group_) {
        my @rg;
        my @temp;
        if (ref $group_ eq 'ARRAY') {
            @temp = @$group_;
        } else {
            push(@temp,$group_);
        }
        foreach my $element (@temp){
            if (my $propercase = validate_response_group($element)) {
                push(@rg,$propercase);
            } else {
                $logger->debug("$element is not a valid ItemSearch response group");
            }
        }
        
        if (int(@rg) > 0) {
            return join(",",@rg);
        } else {
            return DEFAULT_RESPONSE_GROUP;
        }
    } else {
        return DEFAULT_RESPONSE_GROUP;
    }
    
}

sub get_search_index {
    my ($locale,$args,$a_parm) = @_;
    my $logger = get_logger();
    if ($args->{'index'}) {
        my $index = $args->{'index'};
        $logger->trace('arg index: ', $index);
        my $i_hash = $a_parm->{'sparms'};        
        foreach my $i (keys %$i_hash) {
            $logger->trace('p: ', $i);
            if (uc($i) eq uc($index)) {
                 return $i;
            }
        }
    }
    return DEFAULT_INDEX;
      
}

sub get_search_index_parameters {
    my ($locale) = @_;
    my $search_index_parameters = Kynetx::Configure::get_config('SEARCH_INDEX','AMAZON');
    if (defined $search_index_parameters->{$locale}) {
        return $search_index_parameters->{$locale};
    } else {
        return $search_index_parameters->{DEFAULT_LOCALE};
    }
}

sub validate_request {
    my ($request) = @_;
    my $search_index_parameters = Kynetx::Configure::get_config('SEARCH_INDEX','AMAZON');
    if (! has_minimum_parameter($request)){
        my $mins = $search_index_parameters->{'minimum'};
        my $min_err = join(",",keys %$mins);
        return Kynetx::Errors::merror("Request must contain one of these: $min_err");
    } 
    
    if (! $request->{'AssociateTag'}) {
        return Kynetx::Errors::merror("Request must include associate_tag");
    };
    return 1;
}

sub has_minimum_parameter {
    my ($request) = @_;
    my $logger = get_logger();
    my $search_index_parameters = Kynetx::Configure::get_config('SEARCH_INDEX','AMAZON');
    my $mins = $search_index_parameters->{'minimum'};
    $logger->trace("min parms: ",sub {Dumper($request,$mins)});
    foreach my $r_key (keys %$request) {
        if (exists $mins->{$r_key}) {
            return 1;
        }
    }
    return 0;
    
}

sub build {
    my ($request,$args,$locale) = @_;
    my $logger = get_logger();
    my $a_parm = get_search_index_parameters($locale);
    $logger->trace( "isearch: ", sub { Dumper($args) } );
    $request->{'Operation'}='ItemSearch';
    $request->{'ResponseGroup'}=get_response_groups($args);
    $request->{'AssociateTag'} = Kynetx::Predicates::Amazon::get_associate_tag($args);
    my $search_index = get_search_index($locale,$args,$a_parm);
    $logger->trace("SearchIndex: ",$search_index);
    my $item_search_node = 
        $a_parm->{'sparms'}->{$search_index};        
    if (defined $item_search_node) { 
        $request->{'SearchIndex'}=$item_search_node->{'name'};
        my $allowed_parms = $item_search_node->{'item_search_parameters'};
        # try to catch any variations in case
        foreach my $p (@$allowed_parms) {
            my $string = "Parameter: $p ";
            if (defined $args->{$p}) {
                $string .= "hit: ". $args->{$p};
                $request->{$p} = $args->{$p};                
            } elsif (defined $args->{lc($p)}) {
                $string .= "hit: ". $args->{lc($p)};
                $request->{$p} = $args->{lc($p)};
           } elsif (defined $args->{ucfirst($p)} ) {
                $string .= "hit: ". $args->{ucfirst($p)};
                $request->{$p} = $args->{ucfirst($p)};
           }  else {
                $string .= "miss: ";
            }
            $logger->trace($string);
        }
    }

    $logger->debug( "a_request: ", sub { Dumper($request) } );
    my $error =  validate_request($request);
    if (Kynetx::Errors::mis_error($error)) {
        return (Kynetx::Errors::merror($error,"Request failed validation"));
    }  else {
        return $request;  
    }
}


1;
