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
use Data::Dumper;

use Kynetx::Json;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    S_TAG
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my $S_TAG =  "__primitives__";


sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $ug = new Data::UUID;
    my $self = {
        "timestamp"    => DateTime->now->epoch(),
        "guid"         => $ug->create_str(),
        "type"         => undef,
        "domain"         => undef,
        "vars"         => undef,
        "vals"         => undef,
        "req_info"     => undef
    };
    bless($self, $class); # consecrate
    return $self;
}

sub TO_JSON {
    my $self = shift;
    my $logger = get_logger();
    my $hash;
    foreach my $key (keys %$self) {
        $logger->trace("my $key = ",sub {Dumper($self->{$key})});
        $hash->{$key} = $self->{$key};
    }
    my $s = {
      #$S_TAG => JSON::XS::->new->allow_blessed(1)->utf8(1)->encode($hash)
      $S_TAG => JSON::XS::->new->allow_blessed(1)->encode($hash)
    };
    return $s;
}



sub serialize {
    my $self = shift;
    my $logger = get_logger();
    my $hash = $self->TO_JSON();
    return JSON::XS::->new->encode($hash);
}


sub unserialize {
    my $invocant = shift;
    my $logger = get_logger();
    my $class = ref($invocant) || $invocant;
    my ($json) = @_;
    return undef unless (defined $json);
    my $blob = $json;
    my $hash = JSON::XS::->new
            ->filter_json_single_key_object( $S_TAG => sub {
                my $s_primitive = $_[0];
                #my $p_struct = JSON::XS::->new->utf8(1)->decode($s_primitive);
                my $p_struct = JSON::XS::->new->decode($s_primitive);
                bless($p_struct,$class);
            })->decode($json);
    if (! defined $hash || ref $hash eq "") {
        $logger->trace("Source: ", sub {Dumper($hash)});
        return undef;
    }

    return $hash;
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

sub set_domain {
  my $self = shift;
  my $domain = shift;

  return $self->{'domain'} = $domain;
}

sub get_domain {
  my $self = shift;

  return $self->{'domain'};
}

sub isa {
  my $self = shift;
  my $type = shift;
  my $domain = shift;
  my $logger = get_logger();
#  $logger->debug("Checking: ",$self->{'type'}, " for $type");

  return $self->{'type'} eq $type && $self->{'domain'} eq $domain;
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

  $self->{'domain'} = 'web';
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

  $self->{'domain'} = 'web';
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

  $self->{'domain'} = 'web';
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

  $self->{'domain'} = 'web';
  $self->{'type'} = 'change';
  $self->{'element'} = $element;

}


#-----------------------------------------------------------------------------
# generc
#-----------------------------------------------------------------------------

sub generic {
  my $self = shift;
  my($domain, $type) = @_;
  my $logger = get_logger();
  $logger->debug("Generic primitive of: ",$type);

  
  my ($edomain,$etype) = split(/:/,$type);
  $self->{'domain'} = $domain;
  $self->{'type'} = $type;

}




1;

