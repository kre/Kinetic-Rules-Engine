package Kynetx::Modules::PDS;
# file: Kynetx/Modules/PDS.pm
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


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant NAMESPACE => 'PDS';

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $default_actions = {
   'authorize' => {
       js => <<EOF,
function(uniq, cb, config) {
  \$K("body").prepend('<div id="KOBJ_auth_div" style="position:fixed;top:15px;right:15px"></div>');
  //\$K("#KOBJ_auth_div").append('<button id="kButton">Message</button><div id="ktarg" class="kynetx_ui"></div>');
  \$K("#KOBJ_auth_div").append('<button id="kButton">Message</button><div id="ktarg" ></div>');
  //\$K("#ktarg").wrap("<div class='kynetx_ui'></div>");
  \$K("#ktarg").parents('.ui-button:eq(0)').wrap("<div class='kynetx_ui'></div>");
  \$K("#ktarg").html(PDS_auth_notice);
  \$K("#kButton").wrap("<div class='kynetx_ui'></div>");
  \$K("#kButton").button();
  var icons = \$K("#kbutton").button("option","icons");
  \$K("#KOBJ_auth_div").wrap("<div class='kynetx_ui'></div>");
  \$K("#kButton").button( "option", "icons", {secondary:'ui-icon-info'} );  
  \$K("#ktarg").dialog({
  		title: "Know Me",
  		autoOpen : false,
  		show : "drop",
  		modal : true,
  		dialogClass : "alert",
  		stack : true,
  	    buttons: {"Synchronize": 
	  	 	function() {
	  	 		\$K("#ktarg").html("<div>This is the new text</div>");
	  	 	},
	  	 	"No Thanks" : function() {
	  	 		\$K(this).dialog("close");
	  	 	}
  	    }
  	});
  \$K("#ktarg").dialog().parents('.ui-dialog:eq(0)').wrap("<div class='kynetx_ui'></div>");
  //\$K("#pds_auth").wrap();
  \$K("#kButton").click(function() {  		
  		\$K("#kButton").button("option", "label","Standby..."); 
  		\$K("#ktarg").dialog("open"); 		
  		//return false;
  	});
  cb();
}
EOF
       before => \&authorize
   },
};

sub get_resources {
    return     {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}



sub run_function {
    my($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $addr_str = $args->[0];
    my $resp = undef;
    my $found;

    return $resp;
}

sub authorize {
	my ($req_info,$rule_env,$session,$config,$mods)  = @_;
	my $logger= get_logger();
	my $rid = $req_info->{'rid'};
 	my $ruleset_name = $req_info->{"$rid:ruleset_name"};
	my $name = $req_info->{"$rid:name"};
	my $author = $req_info->{"$rid:author"};
	my $description = $req_info->{"$rid:description"};
	my $msg =  <<EOF;
<div id="pds_auth">
<p>The application <strong>$name</string> ($rid) from $author is requesting that you synchronize your account.  </p>
</div>
EOF
	my $js =  Kynetx::JavaScript::gen_js_var('PDS_auth_notice',
		Kynetx::JavaScript::mk_js_str($msg));
		
	return $js;
}

sub authorized {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
 	my $logger = get_logger();
 	
 	return 0;
}

1;
