package Kynetx::Actions::JQueryUI;
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
    effect => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector, effect,speed) {
	    \$K(selector).effect(effect,config,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    toggle => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector, effect,speed) {
	    \$K(selector).toggle(effect,config,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    hide => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector, effect,speed) {
	    \$K(selector).hide(effect,config,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    show => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector, effect,speed) {
	    \$K(selector).show(effect,config,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    switchClass => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector, from_class, to_class,speed) {
	    \$K(selector).switchClass(from_class,to_class,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    removeClass => {
	       'js' => <<EOF,
	function(uniq, cb, config,selector, classname,speed) {
	    \$K(selector).removeClass(classname,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    addClass => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector,classname,speed) {
	    \$K(selector).addClass(classname,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    animate => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector,speed) {
	    \$K(selector).animate(config,speed);
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    datepicker => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector) {
	    \$K(selector).datepicker(config);
	    \$K("#ui-datepicker-div").wrap("<div class='kynetx_ui'></div>");
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    dialog => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector) {
	    if(config.buttons)
	    {
	        config.buttons = eval("(" + config.buttons + ")");
	    }
	    if(config.open)
	    {
	        config.open = eval("(" + config.open + ")");
	    }
	    if(config.modal == "1")
	    {
	        config.modal = true;
	    }
	    if(config.modal == "0")
	    {
	        config.modal = false;
	    }
	    if(config.autoOpen == "1")
	    {
	        config.autoOpen = true;
	    }
	    if(config.autoOpen == "0")
	    {
	        config.autoOpen = false;
	    }

	    \$K(selector).dialog(config);
        \$K(selector).dialog().parents('.ui-dialog:eq(0)').wrap("<div class='kynetx_ui'></div>");   	    
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},
    accordion => {
	       'js' => <<EOF,
	function(uniq, cb, config, selector) {
	    if(config.autoHeight == "1")
	    {
	        config.autoHeight = true;
	    }
	    if(config.autoHeight == "0")
	    {
	        config.autoHeight = false;
	    }

	    \$K(selector).accordion(config);
        \$K(selector).wrap("<div class='kynetx_ui'></div>");   	    
	    cb();
	}
EOF
	  'after' => [\&handle_delay]
	},


};


#sub get_resources {
#    return     {"http://static.kobj.net/kjs-frameworks/jquery_ui/1.8/jquery-ui-1.8.custom.js" => { "type" => "js" },
#    "http://static.kobj.net/kjs-frameworks/jquery_ui/1.8/css/ui-darkness/jquery-ui-1.8.custom.css" => { "type" => "css", "selector" => ".ui-helper-hidden" }
#    };
#}

sub get_resources {
    return     { };
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
