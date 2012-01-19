package Kynetx::Modules::This2That;
# file: Kynetx/Modules/This2That.pm
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
use Data::Dumper;

use XML::XML2JSON;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	get_predicates
	get_resources
	get_actions
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $default_actions = {
};



sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}

my $funcs = {};



sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();
    $logger->trace("Function:", sub {Dumper($function)});
    my $resp = undef;
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info, $function, $args );
    	};
    	if ($@) {
    		$logger->warn("This2That error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module This2That");
    }

    return $resp;
}

sub _xml2json {
	my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $xmlstring = $args->[0];
    my %init_mods;
    $init_mods{'module'} = "JSON::XS";
    if (defined $args->[1] && ref $args->[1] eq "HASH") {
    	my $opts = $args->[1];
    	if ($opts->{'pretty'}) {
    		$init_mods{'pretty'} = 1;
    	}
     	if ($opts->{'force_array'}) {
    		$init_mods{'force_array'} = 1;
    	}
    	if ($opts->{'attribute_prefix'}) {
    		$init_mods{'attribute_prefix'} = $opts->{'attribute_prefix'};
    	}
    	if ($opts->{'content_key'}) {
    		$init_mods{'content_key'} = $opts->{'content_key'};
    	}
    	if ($opts->{'private_elements'} && ref $opts->{'private_elements'} eq "ARRAY") {
    		$init_mods{'private_elements'} = $opts->{'private_elements'};
    	}
     	if ($opts->{'empty_elements'} && ref $opts->{'empty_elements'} eq "ARRAY") {
    		$init_mods{'empty_elements'} = $opts->{'empty_elements'};
    	}
     	if ($opts->{'private_attributes'} && ref $opts->{'private_attributes'} eq "ARRAY") {
    		$init_mods{'private_attributes'} = $opts->{'private_attributes'};
    	}
    	
    }
    my $t2t = XML::XML2JSON->new(%init_mods);
    if (defined $xmlstring && $xmlstring ne "") {
    	my $json = $t2t->convert($xmlstring);
    	if ($args->[1]->{'decode'}) {
    		my $obj = Kynetx::Json::jsonToAst_w($json);
    		return $obj;
    	}
    	return $json;
    }
    
    return undef;
}
$funcs->{'xml2json'} = \&_xml2json;

1;
