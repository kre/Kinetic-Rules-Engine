package Kynetx::Actions::Annotate;
# file: Kynetx/Actions/LetItSnow.pm
# file: Kynetx/Predicates/Referers.pm
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


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my $default_actions = {
    annotate => {
	       'js' => <<EOF,
	function(uniq, cb, config,name) {
        KOBJ.annotate_action(uniq,cb,config,name);
	    cb();
	}
EOF
	  'after' => []
	},
    local_annotate => {
    	       'js' => <<EOF,
    	function(uniq, cb, config,name) {
                    KOBJ.local_annotate_action(uniq,cb,config,name);
    	    cb();
    	}
EOF
    	 'after' => []
    },
    add_annotation => {
    	       'js' => <<EOF,
    	function(uniq, cb, config, annotate_key,html,instance_id) {
            KOBJAnnotateSearchResults.receive_annotation(annotate_key,html,instance_id);
    	    cb();
    	}
EOF
    	 'after' => []
    },
    add_annotation_data => {
    	       'js' => <<EOF,
    	function(uniq, cb, config, annotate_key,data,instance_id) {
            KOBJAnnotateSearchResults.receive_annotation_data(annotate_key,data,instance_id);
    	    cb();
    	}
EOF
    	 'after' => []
    }
};


sub get_resources {
    return  {"https://kns-resources.s3.amazonaws.com/perc_and_annotate/2.0/krl-annotate.js" => { "type" => "js" } };
}

#sub get_resources {
#    return     { };
#}

sub get_actions {
    return $default_actions;
}

my %predicates = ( );

sub get_predicates {
    return \%predicates;
}


1;
