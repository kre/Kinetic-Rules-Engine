package Kynetx::Events::Primitives;
# file: Kynetx/Events/Primitives.pm
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

