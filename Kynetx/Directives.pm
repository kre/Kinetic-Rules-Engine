package Kynetx::Directives;
# file: Kynetx/Directives.pm
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
    $logger->debug("Created new directive with: ",$type);
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
  my $name = shift;
  my $opts = shift;
  my $direct = Kynetx::Directives->new($name);
#  $logger->debug("Directive options are: ", sub {Dumper($opts)});
  $direct->set_options($opts);
  push @{$req_info->{'directives'}}, $direct;
}

sub emit_js {
  my $req_info = shift;
  my $js = shift;
  send_directive($req_info,
		 "emit_js",
		 {'js' => $js});
}

sub send_data {
  my $req_info = shift;
  my $data = shift;
  send_directive($req_info,
		 "data",
		 $data);
}

sub send_raw {
  my $req_info = shift;
  my $data = shift;
  my $type = shift;
  send_directive($req_info,
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

  my $ol = $self->options();

  my $options;
  my $meta;
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


sub gen_directive_document {
  my $req_info = shift;

  my $logger = get_logger();

  my @directives = map {$_->to_directive()} @{$req_info->{'directives'}};

  my $directive_doc = {'directives' => \@directives,
		      };
  
#  $logger->debug("Directives ", sub {Dumper $directive_doc });
  return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(0)->encode(
	   $directive_doc
        );
}

1;
