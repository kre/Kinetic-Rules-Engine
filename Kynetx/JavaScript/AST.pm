package Kynetx::JavaScript::AST;
# file: Kynetx/JavaScript/AST.pm
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
#use warnings;
no warnings qw(uninitialized);


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

use Data::Dumper;
$Data::Dumper::Indent = 1;


sub new {
  my $invocant = shift;
  my $eid = shift;
  my $class = ref($invocant) || $invocant;
  my $self = {'eid' => $eid,
	      'rids' => [],
              'context_id' => undef,
	      'contexts' => {},
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

sub get_context_id {
  my $self = shift;
  return $self->{'context_id'};
}

sub get_context {
  my $self = shift;
  my $cid = shift;
  return $self->{'contexts'}->{$cid};
}

sub update_context {
  my $self = shift;
  my $rid = shift;
  if (! defined $self->{'context_id'}) {
    $self->{'context_id'} = 0;
  } else {
    $self->{'context_id'}++;
  }
  $self->{'contexts'}->{$self->{'context_id'}} = {'rules' => [],
						  'rid' => $rid,
						 };
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
  my $context_id = shift;
  return $self->{'contexts'}->{$context_id}->{'rules'};
}

sub add_rule_js {
  my $self = shift;
  my $rid = shift;
  my $js = shift;
  push @{$self->{'contexts'}->{$self->get_context_id()}->{'rules'}}, $js;
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
  
  # degenerate case where the ruleset was empty (no schedule)
  return $js unless defined $self->get_context_id();

  foreach my $context_id (0..$self->get_context_id()) {

    my $context = $self->get_context($context_id);
    my $rid = $context->{'rid'};
#    $logger->debug("The context ", sub {Dumper $self});
    $logger->debug("Generating JS for $rid in context $context_id");

    my $rjs = '';

    foreach my $rule_js (@{$self->get_rules($context_id)}) {
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
  $logger->trace("JS is: $js");
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
