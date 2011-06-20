package Kynetx::Modules::This2That;
# file: Kynetx/Modules/This2That.pm
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
