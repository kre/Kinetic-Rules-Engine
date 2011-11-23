package Kynetx::Directives;
# file: Kynetx/Directives.pm
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

use JSON::XS;
use Data::Dumper;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
send_directive
send_data
emit_js
to_directive
set_options
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



sub new {
    my $logger = get_logger();
    my $invocant = shift;
    my $type = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {
	"type"         => $type,
	"options"      => undef,
    };
    bless($self, $class); # consecrate
    $logger->debug("Created new directive with: ", $type);
    return $self;
}


sub type {
  my $self = shift;
  return $self->{'type'};
}

sub set_options {
  my $self = shift;
  my $opts = shift;
  $self->{'options'} = $opts;
  return $self;
}

sub options {
  my $self = shift;
  return $self->{'options'};
}

sub send_directive {
  my $logger = get_logger();
  my $req_info = shift;
  my $dir_doc = shift;
  my $name = shift;
  my $opts = shift;
  my $direct = Kynetx::Directives->new($name);
  $logger->trace("Directive options are: ", sub {Dumper($opts)});
  $direct->set_options($opts);
  $dir_doc->add($direct);
#  push @{$req_info->{'directives'}}, $direct;
}

sub emit_js {
  my $req_info = shift;
  my $dir_doc = shift;
  my $js = shift;
  send_directive($req_info,
		 $dir_doc,
		 "emit_js",
		 {'js' => $js});
}

sub send_data {
  my $req_info = shift;
  my $dir_doc = shift;
  my $data = shift;
  send_directive($req_info,
		 $dir_doc,
		 "data",
		 $data);
}

sub send_raw {
  my $req_info = shift;
  my $dir_doc = shift;
  my $data = shift;
  my $type = shift;
  send_directive($req_info,
		 $dir_doc,
		 "raw",
		 {'content' => $data,
		  'type' => $type
		 });
}

# these have to match the standard options in
#    Kynetx::Actions::build_one_action::$config
my $filter_out = {
   'txn_id' => 1,
   'rule_name' => 1,
   'rid' => 1,
};

sub to_directive {
  my $self = shift;
  my $eid = shift;

  my $ol = $self->options();

  my $options;
  my $meta = {'eid', $eid};
  foreach my $k (keys %{$ol}) {
    if ($filter_out->{$k}) {
      $meta->{$k} = $ol->{$k};
    } else {
      $options->{$k} = $ol->{$k};
    }
  }

  return { 'name' => $self->type(),
	   'options' => $options,
	   'meta' => $meta,

	 };
}



1;
