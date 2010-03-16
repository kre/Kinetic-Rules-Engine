package Kynetx::Authz;
# file: Kynetx/Authz.pm
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

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Kynetx::Session qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Json qw/:all/;

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
is_authorized
authorize_message
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub is_authorized {
  my ($rid, $ruleset, $session) = @_;
  
  my $authorized = 1;
  # if there's no authz directive, we're authorized
  if (defined $ruleset->{'meta'}->{'authz'}) {
    my $type = $ruleset->{'meta'}->{'authz'}->{'type'};
    my $level = $ruleset->{'meta'}->{'authz'}->{'level'};
    my $tokens = get_authz_tokens($session);
    if ($tokens->{$rid}) {
      if ($tokens->{$rid}->{'type'} eq $type &&
	  $tokens->{$rid}->{'level'} eq $level) {
	$authorized = 1;
      } else {
	$authorized = 0;
      }
    } else {
      $authorized = 0;
    }
  } else {
    $authorized = 1;
  }
  return $authorized;
}

sub authorize_message {
  my($req_info, $session, $ruleset) = @_;

  my $logger = get_logger();

  my $js = '';


  my $rid = $req_info->{'rid'};

  my $ruleset_name = $ruleset->{'ruleset_name'} || 'unknown';
  my $name = $ruleset->{'meta'}->{'name'} || 'unknown';
  my $author = $ruleset->{'meta'}->{'author'} || 'unknown';
  my $description = $ruleset->{'meta'}->{'description'} || 'unknown';

  my $session_id = Kynetx::Session::session_id($session) || 'unknown';

  my $image_url = Kynetx::Configure::get_config('BASE_MARKETPLACE_IMAGE_URL') . 
                  $session_id;

  my $auth_url = Kynetx::Configure::get_config('BASE_AUTHZ_URL') . $rid;


  my $msg =  <<EOF;
<div id="KOBJ_ruleset_activation">
<img align="center" src="$image_url"/>
<p>The application $name ($rid) from $author must be activated before you can use it.  </p>
<div><b>Description:</b>$description</div>
<p>
<div style="color: #000; background-color: #FFF; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"">
<a href="$auth_url">Activate!</a></div>

<div style="color: #FFF; background-color: #F33; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"" onclick="javascript:KOBJ.close_notification('#KOBJ_ruleset_activation')">No Thanks!</div>
</div>
EOF

  $js .=  Kynetx::JavaScript::gen_js_var('KOBJ_authz_notice',
		   Kynetx::JavaScript::mk_js_str($msg));

  my $args = [];
  my $config = {'sticky' => 1};
  # add to front of arg str (in reverse)
  unshift @{ $args }, astToJson($config);
  unshift @{ $args }, 'function(){}';
  unshift @{ $args }, mk_js_str(time);

  my $arg_str = join(',', @{ $args }) || '';

  $js .= <<_JS_;
(function(uniq, cb, config) {
  \$K.kGrowl.defaults.header = "App Activation";
  if(typeof config === 'object') {
    jQuery.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_authz_notice);
  cb();
} ($arg_str))
_JS_

  return $js;
}

sub get_authz_tokens {
  my($session) = @_;
  return $session->{'chico'}->{'authz_tokens'};
}



1;
