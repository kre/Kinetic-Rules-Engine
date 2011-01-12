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

use Kynetx::Session qw(
	process_session
	session_cleanup
);


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
   'authenticate' => {
       js => <<EOF,
function(uniq, cb, config) {
  var myken = \$K("toKEN");
  var cook = \$K("document.cookie");
  \$K("body").prepend('<div id="KOBJ_auth_div" style="position:fixed;top:15px;right:15px"></div>');
  //\$K("#KOBJ_auth_div").append('<button id="kButton">Message</button><div id="ktarg" ></div>');
  \$K("#KOBJ_auth_div").append('<div id="kButton" title="Message" name="Message"></div><div id="ktarg" ></div>');
  //\$K("#ktarg").wrap("<div class='kynetx_ui'></div>");
  \$K("#ktarg").parents('.ui-button:eq(0)').wrap("<div class='kynetx_ui'></div>");
  \$K("#ktarg").html(PDS_auth_notice);
  \$K("#kButton").wrap("<div class='kynetx_ui'></div>");
  \$K("#kButton").button({
  		label : "Message"
  });
  var icons = \$K("#kbutton").button("option","icons");
  \$K("#KOBJ_auth_div").wrap("<div class='kynetx_ui'></div>");
  \$K("#kButton").button( "option", "icons", {secondary:'ui-icon-info'} );  
  \$K("#ktarg").dialog({
  		title: "Know Me",
  		autoOpen : false,
  		show : "drop",
  		//hide : "fade",
  		modal : true,
  		dialogClass : "alert",
  		stack : true,
  	    buttons: {"Synchronize": 
	  	 	function() {
	  	 		\$K("#KOBJ_auth_form").submit();	  	 		
	  	 		\$K("#ktarg").html("<div>Authorizing...</div>");
	  	 	},
	  	 	"No Thanks" : function() {	  	 		
	  	 		\$K("#kButton").button("destroy");
	  	 		\$K("#kButton").remove();
	  	 		\$K(this).dialog("widget").effect("drop",{},500);
	  	 	}
  	    }
  	});
  \$K("#ktarg").dialog().parents('.ui-dialog:eq(0)').wrap("<div class='kynetx_ui'></div>");
  //\$K("#pds_auth").wrap();
  \$K("#kButton").click(function() {  		  	    
  		\$K("#kButton").button("option", "label","Standby...");  		
  		\$K("#ktarg").dialog("open");
  		\$K("#kButton").button("disable"); 		
  		//return false;
  	});
  cb();
}
EOF
       before => \&authenticate
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

sub authenticate {
	my ($req_info,$rule_env,$session,$config,$mods)  = @_;
	my $logger= get_logger();
	my $rid = $req_info->{'rid'};
 	my $ruleset_name = $req_info->{"$rid:ruleset_name"};
	my $name = $req_info->{"$rid:name"};
	my $author = $req_info->{"$rid:author"};
	my $description = $req_info->{"$rid:description"};
	my $gid = $req_info->{'g_id'};
	my $cken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $caller = $req_info->{'caller'};
	my $msg =  <<EOF;
<div id="pds_auth">
<p>The application <strong>$name</string> ($rid) from $author is requesting that you synchronize your account.  </p>
<p>$cken</p>
 <form id="KOBJ_auth_form" method="GET" action='http://64.55.47.131:8082/ruleset/pds_callback/$rid/foo/bar'>
  	<label for="toKEN">KEN</label>
  	<input type="text" name="toKEN" value="" class="text ui-widget-content ui-corner-all"/>
	<input type="hidden" name="CID" value=$gid />
	<input type="hidden" name="cKEN" value=$cken />
	<input type="hidden" name="caller" value=$caller />
  </form>
</div>
EOF
	my $js =  Kynetx::JavaScript::gen_js_var('PDS_auth_notice',
		Kynetx::JavaScript::mk_js_str($msg));
		
	return $js;
}

sub authenticated {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
 	my $logger = get_logger();
 	
 	return 0;
}


sub process_auth_callback {
  my($r, $method, $rid) = @_;
  my $logger = get_logger();

  # we have to contruct a whole request env and session
  my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);
  my $ck = $req_info->{'CID'};
  my $oKen = $req_info->{'cKEN'};
  my $passed = $req_info->{'toKEN'};
  my $session = process_session($r);
  my $req = Apache2::Request->new($r);
  my $caller    = $req->param('caller');
  $logger->debug("PDS: ",sub {Dumper($req_info)});
  if ($oKen eq Kynetx::Persistence::KEN::get_ken($session,$rid)) {
  	$logger->debug("KENS match!");
  	my $newuser = Kynetx::Persistence::KEN::get_ken_value($passed,"username");
  	if ($newuser) {
  		$logger->debug("Found $newuser");
  		my $token = Kynetx::Persistence::KToken::get_token($session,$rid);
  		my $new_token = Kynetx::Persistence::KToken::new_token($rid,$session,$passed,1);
  		if ($token) {
  			$logger->debug("Token for $oKen is ($token)");
  		}
  		if ($new_token) {
  			$logger->debug("New token is ($new_token)");
  			Kynetx::Persistence::KToken::delete_token($token,$session,$rid);
  		}
  	} else {
  		my $actual = Kynetx::Persistence::KEN::get_ken_value($oKen,"username");
  		$logger->debug("$passed not found, current user is: $actual");
  	}
  }
  $r->headers_out->set( Location => $caller );
  session_cleanup($session,$req_info);

}

1;
