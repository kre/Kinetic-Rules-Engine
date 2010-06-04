package Kynetx::Events::Primitives;
# file: Kynetx/Events/Primitives.pm
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


sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $ug = new Data::UUID;
    my $self = {
	"timestamp"    => DateTime->now->epoch(), 
	"guid"         => $ug->create_str(),
	"type"         => undef,
	"vars"         => undef,
        "vals"         => undef,
        "req_info"     => undef
    };
    bless($self, $class); # consecrate
    return $self;
}

sub timestamp {
  my $self = shift;
  return $self->{'timestamp'};
}

sub guid {
  my $self = shift;
  return $self->{'guid'};
}

sub happened_before {
  my $self = shift;
  my $other = shift;

  return $self->{'timestamp'} <= $other->{'timestamp'};

}

sub is {
  my $self = shift;
  my $other = shift;

  return ($self->{'guid'} eq $other->{'guid'});
}

sub different_than {
  my $self = shift;
  my $other = shift;

  return ! ($self->{'guid'} eq $other->{'guid'});
}

sub set_type {
  my $self = shift;
  my $type = shift;

  return $self->{'type'} = $type;
}

sub get_type {
  my $self = shift;

  return $self->{'type'};
}

sub isa {
  my $self = shift;
  my $type = shift;

  return $self->{'type'} eq $type;
}


sub set_vars {
  my $self = shift;
  my $id = shift;
  my $vars = shift;

  return $self->{'vars'}->{$id} = $vars;
}

sub get_vars {
  my $self = shift;
  my $id = shift;

  return $self->{'vars'}->{$id} || [];
}


sub set_vals {
  my $self = shift;
  my $id = shift;
  my $vals = shift;

  return $self->{'vals'}->{$id} = $vals;
}

sub get_vals {
  my $self = shift;
  my $id = shift;

  return $self->{'vals'}->{$id} || [];
}


sub set_req_info {
  my $self = shift;
  my $req_info = shift;

  return $self->{'req_info'} = $req_info;
}

sub get_req_info {
  my $self = shift;

  return $self->{'req_info'};
}



#-------------------------------------------------------------------------------------
# pageview
#-------------------------------------------------------------------------------------

sub pageview {
  my $self = shift;
  my($url) = @_;

  $self->{'type'} = 'pageview';
  $self->{'url'} = $url;
  
}

sub url {
  my $self = shift;
  return $self->{'url'}
}



#-------------------------------------------------------------------------------------
# click
#-------------------------------------------------------------------------------------

sub click {
  my $self = shift;
  my($element) = @_;

  $self->{'type'} = 'click';
  $self->{'element'} = $element;

}

sub element {
  my $self = shift;
  return $self->{'element'}
}



#-------------------------------------------------------------------------------------
# submit
#-------------------------------------------------------------------------------------

sub submit {
  my $self = shift;
  my($element,$url) = @_;

  $self->{'type'} = 'submit';
  $self->{'element'} = $element;
  $self->{'url'} = $url;

}



#-----------------------------------------------------------------------------
# change
#-----------------------------------------------------------------------------

sub change {
  my $self = shift;
  my($element) = @_;

  $self->{'type'} = 'change';
  $self->{'element'} = $element;

}


#-----------------------------------------------------------------------------
# generc
#-----------------------------------------------------------------------------

sub generic {
  my $self = shift;
  my($type) = @_;

  $self->{'type'} = $type;

}




1;

