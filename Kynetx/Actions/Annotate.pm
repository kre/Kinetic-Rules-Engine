package Kynetx::Actions::Annotate;
# file: Kynetx/Actions/LetItSnow.pm
# file: Kynetx/Predicates/Referers.pm
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
