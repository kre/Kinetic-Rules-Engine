package Kynetx::JavaScript::AST;
# file: Kynetx/JavaScript/AST.pm
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
mk_turtle
KOBJ_ruleset_obj
register_resources
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub new {
  my $invocant = shift;
  my $eid = shift;
  my $class = ref($invocant) || $invocant;
  my $self = {'eid' => $eid,
	      'rids' => [],
	     };
  bless($self, $class); # consecrate
  return $self;
}

sub get_eid {
  my $self = shift;
  return $self->{'eid'};
}

sub add_rid_js {
  my $self = shift;
  my $rid = shift;
  my $mjs = shift;
  my $gjs = shift;
  my $ruleset = shift;
  my $txn_id = shift;
  unless (defined $self->{$rid}) {
    push @{$self->{'rids'}}, $rid;
    $self->{$rid} = {'rules' => []
		    };
  }
  $self->{$rid}->{'global'} = $gjs;
  $self->{$rid}->{'meta'} = $mjs;
  $self->{$rid}->{'ruleset'} = $ruleset;
  $self->{$rid}->{'txn_id'} = $txn_id;
  
}

sub get_global {
  my $self = shift;
  my $rid = shift;
  return $self->{$rid}->{'global'};
}

sub get_meta {
  my $self = shift;
  my $rid = shift;
  return $self->{$rid}->{'meta'};
}

sub get_txn_id {
  my $self = shift;
  my $rid = shift;
  return $self->{$rid}->{'txn_id'};
}

sub get_ruleset {
  my $self = shift;
  my $rid = shift;
  return $self->{$rid}->{'ruleset'};
}

sub get_rules {
  my $self = shift;
  my $rid = shift;
  return $self->{$rid}->{'rules'};
}

sub add_rule_js {
  my $self = shift;
  my $rid = shift;
  my $js = shift;
  push @{$self->{$rid}->{'rules'}}, $js;
}

sub add_resources {
  my $self = shift;
  my $rid = shift;
  my $resources = shift;
  $self->{$rid}->{'resources'} = $resources;
}

sub generate_js {
  my $self = shift;

  my $logger = get_logger();

  my $js = '';
  foreach my $rid (@{$self->{'rids'}}) {

    $logger->debug("Generating JS for $rid");

    my $rjs = '';

    foreach my $rule_js (@{$self->get_rules($rid)}) {
      $rjs .= $rule_js;
    }

    # wrap the rule evals in a try-catch-block
    $rjs = add_errorstack($rid,$self->get_ruleset($rid),$rjs) if $rjs;
    # put it all together
    $rjs = $self->get_meta($rid) . $self->get_global($rid) . $rjs;

    # wrap it up in a closure
    $rjs = mk_turtle($rjs) if $rjs;

    #add verify logging call
    if((Kynetx::Configure::get_config('USE_KVERIFY') || '0') == '1'){
      $rjs .= "KOBJ.logVerify = KOBJ.logVerify || function(t,a,c){};";
      $rjs .= "KOBJ.logVerify('" . $self->get_txn_id($rid) . "', '$rid', '" . Kynetx::Configure::get_config('EVAL_HOST') . "');";
    }
    my $eid = $self->{'eid'} || 'unknown';
    #add verify logging call

    $js .= $self->mk_registered_resource_js($rid);

    $js .= <<EOF;
KOBJ.registerClosure('$rid', function(\$K) { $rjs }, '$eid');
EOF

  }

  return $js;

}

sub add_errorstack {
  my($rid,$ruleset, $js) = @_;
  my $kobj_rs = KOBJ_ruleset_obj($ruleset->{'ruleset_name'});
  my $kobj_rs_name = $ruleset->{'meta'}->{'name'} || 'Anonymous Ruleset';
  my $kobj_rs_id = $rid;
  my $r = <<_JS_;
try { $js } catch (e) { 
KOBJ.errorstack_submit($kobj_rs.keys.errorstack, e, {id : '$kobj_rs_id',name : '$kobj_rs_name'});
};
_JS_
  if($ruleset->{'meta'}->{'keys'}->{'errorstack'}) {
    return $r;
  } else {
    return $js;
  }
}

sub KOBJ_ruleset_obj {
  my($ruleset_name) = @_;
  return "KOBJ['" . $ruleset_name . "']";
}


#
# This will put out the needed code that action use to express
# that they have external js or css.  If no resources are need
# it just return ""
#
sub mk_registered_resource_js {
   my($self, $rid) = @_;

   # For each resource lets make a register resources call.
   my $register_resources_js = '';

   my $logger = get_logger();


   $logger->debug("Generating resource statement for $rid");

   if($self->{$rid}->{'resources'}) {

     my $register_resources_json = Kynetx::Json::encode_json($self->{$rid}->{'resources'});
     # $logger->debug("Req info for register resources ",  $register_resources_json);
     $register_resources_js = "KOBJ.registerExternalResources('" .
       $rid .
	 "', " .
	   $register_resources_json .
	     ");";

   }
   return $register_resources_js;
}

sub register_resources {
   my($req_info, $resources) = @_;
   # Add the needed resources
   # These are the urls of either js or css that need to be added because an 
   # action needs them before they execute
   if($resources) {
        while( my ($k, $v) = each %$resources ) {
            $req_info->{'resources'}->{$k} = $v;
        }
    }
}



sub mk_turtle {
  my($js) = @_;
  return '(function(){' . $js . "}());\n";
}

1;
