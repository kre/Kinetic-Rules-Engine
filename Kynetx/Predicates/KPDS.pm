
package Kynetx::Predicates::KPDS;
# file: Kynetx/Predicates/KPDS.pm
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

use Apache2::Const;

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON::XS;

use Data::Dumper;


use Kynetx::OAuth;
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Util qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
eval_kpds
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

#
# NAMESPACE is the name the Parser assigns to keys in the keys from the meta block
#
use constant NAMESPACE => 'kpds';
use constant BASE_KPDS_URL => 'http://kpds.kynetx.com/infobase/';

#Request Token URL  http://accounts-staging.kynetx.com/oauth/request_token
#Access Token URL http://accounts-staging.kynetx.com/oauth/access_token
#Authorize URL http://accounts-staging.kynetx.com/oauth/authorize 

my $urls = {request_token_url => 'http://accounts-staging.kynetx.com/oauth/request_token',
	    access_token_url  => 'http://accounts-staging.kynetx.com/oauth/access_token',
	    authorization_url => 'http://accounts-staging.kynetx.com/oauth/authorize',
	   };

my %predicates = (

);

sub get_predicates {
    return \%predicates;
}

my $actions = {
   'authorize' => {
       js => <<EOF,
function(uniq, cb, config) {
  \$K.kGrowl.defaults.header = "Authorize KPDS Access";
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_kpds_notice);
  cb();
}
EOF
       before => \&authorize
   },

};

sub get_actions {
    return $actions;
}


my $funcs = {};

sub authorized {
 my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
 my $logger = get_logger();

 my $rid = $req_info->{'rid'};

 $logger->debug("Checking KPDS access for rule $rule_name in $rid");

 $logger->debug("Session in authorized: ", sub { Dumper $session});

 my $nt = Kynetx::OAuth->new(NAMESPACE, $req_info, $session, $urls);
 
 if ($nt->authorized()) {

   my $url = BASE_KPDS_URL . '7795';
  

   $logger->debug("Trying $url");


   my $response = eval {$nt->get_restricted_resource($url)};


   if ($@ || ! $response->is_success) {
     my $status = $@ || $response->status;
     $logger->debug("Not authorized: ", $status);
     return 0;
   } else {
     $logger->debug("Got ", $response->content);
     return 1;
   }
   
   
 } else {
   return  0;
 }
 
 
}
$funcs->{'authorized'} = \&authorized;

sub authorize {
 my ($req_info,$rule_env,$session,$config,$mods)  = @_;

 my $logger= get_logger();

 my $nt = Kynetx::OAuth->new(NAMESPACE, $req_info, $session, $urls);

 my $rid = $req_info->{'rid'};

 my $base_cb_url = 'http://' . 
                   Kynetx::Configure::get_config('OAUTH_CALLBACK_HOST').
   	           ':'.Kynetx::Configure::get_config('OAUTH_CALLBACK_PORT') . 
		   "/ruleset/kpds_callback/$rid?";

 my $version = $req_info->{'rule_version'} || 'prod';

 my $callback_url = mk_url($base_cb_url,
		   {'caller',$req_info->{'caller'}, 
		    "$rid:kynetx_app_version", $version});

 $logger->debug("requesting authorization URL with oauth_callback => $callback_url");

 $nt->callback($callback_url);
 my $auth_url = eval {
   $nt->get_authorization_url()
 };
 if( $@ ) {
   $logger->warn("request for authorization URL from " . $urls->{'authorization_url'} ." failed: ", $@);
   return '';
 }
 
 $nt->store_request_secret($nt->request_token_secret);

 $logger->debug("Got $auth_url ... sending user an authorization invitation");


 my $ruleset_name = $req_info->{"$rid:ruleset_name"};
 my $name = $req_info->{"$rid:name"};
 my $author = $req_info->{"$rid:author"};
 my $description = $req_info->{"$rid:description"};

 my $msg =  <<EOF;
<div id="KOBJ_kpds_auth">
<p>The application $name ($rid) from $author is requesting that you authorize KPDS to share your personal information with it.  </p>
<blockquote><b>Description:</b>$description</blockquote>
<p>
The application will not have access to your login credentials at KPDS.  If you click "Take me to KPDS" below, you will taken to KPDS and asked to authorize this application.  You can cancel at that point or now by clicking "No Thanks" below.  Note: if you cancel, this application may not work properly. After you have authorized this application, you will be redirected back to this page.
</p>
<div style="color: #000; background-color: #FFF; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"">
<a href="$auth_url">Take me to KPDS</a></div>

<div style="color: #FFF; background-color: #F33; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"" onclick="javascript:KOBJ.close_notification('#KOBJ_kpds_auth')">No Thanks!</div>
</div>
EOF

 my $js =  Kynetx::JavaScript::gen_js_var('KOBJ_kpds_notice',
		   Kynetx::JavaScript::mk_js_str($msg));

 return $js
 
}

sub process_oauth_callback {
  my($r, $method, $rid) = @_;

  my $logger = get_logger();

  # we have to contruct a whole request env and session
  my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);
  my $session = process_session($r);

  my $req = Apache2::Request->new($r);
  my $request_token = $req->param('oauth_token');
  my $verifier      = $req->param('oauth_verifier');
  my $caller        = $req->param('caller');

  $logger->debug("User returned from KPDS with oauth_token => $request_token &  oauth_verifier => $verifier & caller => $caller");

  my $nt = Kynetx::OAuth->new(NAMESPACE, $req_info, $session, $urls);

#  $logger->debug("Successfully created KPDS object");

  $nt->request_token($request_token);
  $nt->set_token_secret();


  # exchange the request token for access tokens
  my ($access_token, $access_token_secret) = 
    $nt->request_access_token(verifier => $verifier);


#  $logger->debug("Session before store: ", sub { Dumper $session});

  $logger->debug("Exchanged request tokens for access tokens. access_token => $access_token & secret => $access_token_secret");


    $nt->store_access_tokens({
         access_token        => $access_token,
         access_token_secret => $access_token_secret,
     });

  $logger->debug("Session after store: ", sub { Dumper $session});
 

  $logger->debug("redirecting newly authorized tweeter to $caller");
  $r->headers_out->set(Location => $caller);
  session_cleanup($session);

}


# http://kpds.kynetx.com/infobase/<element number>

# Here are the elements:
#      '7795' => 'Investments - Stocks / Bonds',
#      '8165' => 'Vehicle - Truck/Motorcycle/RV Owner',
#      '8600' => 'Adult Age Ranges Present in Household',
#      '8601' => 'Children''s Age Ranges - New',
#      '8602' => 'Number of Children - New',
#      '8604' => 'Occupation - 1st Individual',
#      '8606' => 'Home Owner / Renter',
#      '8607' => 'Length of Residence',
#      '8608' => 'Dwelling Type',
#      '8609' => 'Marital Status in the Household',
#      '8614' => 'Base Record Verification Date',
#      '8615' => 'Mail Order Buyer',
#      '8616' => 'Age in Two-Year Increments - 1st Individual',
#      '8619' => 'Working Woman',
#      '8620' => 'Mail Order Responder',
#      '8621' => 'Credit Card Indicator',
#      '8622' => 'Presence of Children - New',
#      '8626' => 'Age in Two-Year Increments - Input Individual',
#      '8628' => 'Number of Adults',
#      '8629' => 'Household Size',
#      '8637' => 'Occupation - Input Individual',
#      '8641' => 'Income - Estimated Household',
#      '8642' => 'Home Market Value',
#      '8647' => 'Vehicle - Known Owned Number',
#      '8648' => 'Vehicle - Dominant Lifestyle Indicator',
#      '8688' => 'Gender - Input Individual',
#      '9300' => 'Personicx Cluster Code',
#      '9509' => 'Education - 1st Individual',
#      '9514' => 'Education - Input Individual',
#      '9533' => 'Race Code - Input Individual'


my $code_to_function = {
'7795' => 'investments', # 'Investments - Stocks / Bonds',
'8165' => 'vehicle', # 'Vehicle - Truck/Motorcycle/RV Owner',
'8600' => 'adult_age_range', # 'Adult Age Ranges Present in Household',
'8601' => 'children_age_range', # 'Childrens Age Ranges - New',
'8602' => 'number_of_children', # 'Number of Children - New',
'8604' => 'occupation', # 'Occupation - 1st Individual',
'8606' => 'home_owner_or_renter', # 'Home Owner / Renter',
'8607' => 'length_of_residence', # 'Length of Residence',
'8608' => 'dwelling_type', # 'Dwelling Type',
'8609' => 'marital_status_household', # 'Marital Status in the Household',
'8614' => 'record_verification_date', # 'Base Record Verification Date',
'8615' => 'mail_order_buyer', # 'Mail Order Buyer',
'8616' => 'age_first_indv', # 'Age in Two-Year Increments - 1st Individual',
'8619' => 'working_woman', # 'Working Woman',
'8620' => 'mail_order_responder', # 'Mail Order Responder',
'8621' => 'credit_card_indicator', # 'Credit Card Indicator',
'8622' => 'presence_of_children', # 'Presence of Children - New',
'8626' => 'age_of_input_indv', # 'Age in Two-Year Increments - Input Individual',
'8628' => 'number_of_adults', # 'Number of Adults',
'8629' => 'household_size', # 'Household Size',
'8637' => 'occupation_of_input_indv', # 'Occupation - Input Individual',
'8641' => 'estimated_household_income', # 'Income - Estimated Household',
'8642' => 'home_market_value', # 'Home Market Value',
'8647' => 'number_of_vehicles', # 'Vehicle - Known Owned Number',
'8648' => 'vehicle_dominant_lifestyle_indicator', # 'Vehicle - Dominant Lifestyle Indicator',
'8688' => 'gender_of_input_indv', # 'Gender - Input Individual',
'9300' => 'personix_cluster_code', # 'Personicx Cluster Code',
'9509' => 'education_of_first_indv', # 'Education - 1st Individual',
'9514' => 'education_of_input_indv', # 'Education - Input Individual',
'9533' => 'race_of_input_indv', # 'Race Code - Input Individual'
};

sub eval_kpds {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
  my $logger = get_logger();
  $logger->debug("eval_kpds evaluation with function -> ", $function);
  my $f = $funcs->{$function};
  if (defined $f) {
    return $f->($req_info,$rule_env,$session,$rule_name,$function,$args);
  } else {

    if(not defined $req_info->{'kpds'}->{$function}) {

      my $nt = Kynetx::OAuth->new(NAMESPACE, $req_info, $session, $urls);
      my $url = BASE_KPDS_URL . 'all';

      $logger->debug("Getting data from ", $url);

      my $response = eval { $nt->get_restricted_resource($url) };

      if ($@) {
	$logger->warning("Bad response from KPDS: $@");
	return;
      }
      

      unless ($response->is_success) {
	$logger->warn("Failed to get authorized content from $url");
	return '';
      }

      my $data = decode_json($response->content);

#      $logger->debug("Got ", sub {Dumper $data});


      foreach my $item (@{ $data->{'data'} }) {
#	$logger->debug("Item: ", sub {Dumper $item});
	my $func = $code_to_function->{$item->{'name'}} if defined $item->{'name'};
	$req_info->{'kpds'}->{$func} = $item->{'value'} if defined $func;
#	$req_info->{'kpds'}->{$func} = {'value' => $item->{'value'},
#					'label' => $item->{'label'}};
      }
    }

    $logger->debug("KPDS data for $function -> " ,
		   $req_info->{'kpds'}->{$function});

    return $req_info->{'kpds'}->{$function};

    

  }
}


1;
