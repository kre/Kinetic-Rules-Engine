package Kynetx::Actions::LetItSnow;
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
    let_it_snow => {
		    'js' => <<EOF,
    function(uniq, cb, config) {
	KOBJ.letitsnow(config);
	cb();
}
EOF
		    'after' => [ \&handle_delay ]

	}
};

my $external_resource =  {
};


sub get_resources {
    return $external_resource;
}

sub get_actions {
    return $default_actions;
}

my %predicates = ( );

sub get_predicates {
    return \%predicates;
}

sub handle_delay {
 my ($js,$req_info,$rule_env,$session,$config,$mods)  = @_;

 if (defined $mods && $mods->{'delay'}) {
   my $rule_name = $config->{'rule_name'};
   my $delay_cb =
     ";KOBJ.logger('timer_expired', '" .
       $req_info->{'txn_id'} . "'," .
	 "'none', '', 'success', '" .
	   $rule_name . "','".
	     $req_info->{'rid'} .
	       "');";

   $js .= $delay_cb;  # add in automatic log of delay expiration

   $js = "setTimeout(function() { $js },  ($mods->{'delay'} * 1000) ); \n";
 }

 return $js;

}


1;
