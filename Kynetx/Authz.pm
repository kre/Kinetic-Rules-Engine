package Kynetx::Authz;
# file: Kynetx/Authz.pm
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


use Data::Dumper;
$Data::Dumper::Indent = 1;


use Kynetx::Session qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rids qw/:all/;

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
is_authorized
authorize_message
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub is_authorized {
  my ($rid, $ruleset, $session) = @_;

  # $rid is real RID, not rid_info...

#  my $logger = get_logger();

  my $authorized = 1;
  # if there's no authz directive, we're authorized
  if (defined $ruleset->{'meta'}->{'authz'}) {
    my $type = $ruleset->{'meta'}->{'authz'}->{'type'};
    my $level = $ruleset->{'meta'}->{'authz'}->{'level'};
    my $tokens = get_authz_tokens($session);
#    $logger->debug("Got tokens ", sub { Dumper $tokens});
    if (defined $tokens && $tokens->{$rid}) {
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


  my $rid = get_rid($req_info->{'rid'});

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
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_authz_notice);
  cb();
} ($arg_str))
_JS_

  return $js;
}

sub get_authz_tokens {
  my($session) = @_;
  my $tokens = Kynetx::Persistence::get_persistent_var("ent","chico",$session,"authz_tokens");
  return $tokens;
}



1;
