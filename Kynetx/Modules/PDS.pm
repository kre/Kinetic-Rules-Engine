package Kynetx::Modules::PDS;
# file: Kynetx/Modules/PDS.pm
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

my $funcs = {};

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
   'revoke' => {
   		js => <<EOF,
function(uniq, cb, config) {
	\$K("body").append("<div id=myKlogout></div>");	
	\$K("#myKlogout").dialog({
		title : "Logging out",
		//autoOpen : true,
		//dialogClass : "alert",
		//stack : true,
		modal : true,
		buttons: {
			Ok: function() {
				\$K(this).dialog("close");
			}
		}
	});
	\$K("#myKlogout").dialog().parents('.ui-dialog:eq(0)').wrap("<div class='kynetx_ui'></div>");
	cb();   	
}	
EOF
		after =>[\&revoke_session]
   }
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
	my $rid = $req_info->{'rid'};
 	my $logger = get_logger();
 	return Kynetx::Persistence::KToken::is_authenticated($session,$rid);
}
$funcs->{'authenticated'} = \&authenticated;

sub revoke_session {
	my ($js,$req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
	my $rid = $req_info->{'rid'};
 	my $logger = get_logger();
	my $token = Kynetx::Persistence::KToken::get_token($session,$rid)->{'ktoken'};
	my $session_id = Kynetx::Session::session_id($session);
	Kynetx::Persistence::KToken::delete_token($token,$session_id,$rid);
	return 1;
}
$funcs->{'revoke'} = \&revoke_session;


sub run_function {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $f = $funcs->{$function};
    if (defined $f) {
     	return $f->($req_info,$rule_env,$session,$rule_name,$function,$args);
    } else {
    	$logger->warn("Function $function not found in module PDS");
    }

    return undef;
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
  my $current = Kynetx::Persistence::KEN::get_ken($session,$rid);
  $logger->debug("PDS: ",sub {Dumper($req_info)});
  $logger->debug("Current: $current");
  $logger->debug("Passed: $passed");
  if ($oKen eq $current) {
  	$logger->debug("KENS match!");
  	my $newuser = Kynetx::Persistence::KEN::get_ken_value($passed,"username");
  	if ($newuser) {
  		$logger->debug("Found $newuser");
  		my $token = Kynetx::Persistence::KToken::get_token($session,$rid)->{'ktoken'};
  		my $new_token = Kynetx::Persistence::KToken::new_token($rid,$session,$passed,1);
  		if ($token) {
  			$logger->debug("Token for $oKen is ($token)");
  		}
  		if ($new_token) {
  			$logger->debug("New token is ($new_token)");
			my $session_id = Kynetx::Session::session_id($session);
			Kynetx::Persistence::KToken::delete_token($token,$session_id,$rid);
  		}
  	} else {
  		my $actual = Kynetx::Persistence::KEN::get_ken_value($oKen,"username");
  		$logger->debug("$passed not found, current user is: $actual");
  	}
  } else {
  	
  }
  $r->headers_out->set( Location => $caller );
  session_cleanup($session,$req_info);

}

1;
