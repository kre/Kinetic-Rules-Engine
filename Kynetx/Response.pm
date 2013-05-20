package Kynetx::Response;
# file: Kynetx/Response.pm
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

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use HTML::Template;
use Apache2::Const -compile => qw/OK :http/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Kynetx::Session qw/session_cleanup/;
use Kynetx::Log;
use Kynetx::Directives;
use Kynetx::Util;

sub create_directive_doc {
  my $invocant = shift;
  my $eid = shift;
  my $class = ref($invocant) || $invocant;
  my $self = {'directives' => [],
	      'eid' => $eid,
	     };
  bless($self, $class); # consecrate
  return $self;
}


sub add {
  my $self = shift;
  my $directive = shift;

  my $logger = get_logger();
  $logger->debug("Adding new directive ", $directive->type());

  return push(@{$self->{'directives'}}, $directive);
}

sub directives {
  my $self = shift;
  return $self->{'directives'};
}

sub gen_directive_document {
  my $self = shift;

  my $logger = get_logger();

  my $eid = $self->{'eid'};

  my @directives = map {$_->to_directive($eid)} @{$self->{'directives'}};

  my $directive_doc = {'directives' => \@directives,
		      };
  
#  $logger->debug("Directives ", sub {Dumper $directive_doc });
#  return JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(0)->encode(
#	   $directive_doc
#        );
  return JSON::XS::->new->convert_blessed(1)->pretty(0)->encode(
	   $directive_doc
        );
}

# sub gen_directive_document {
#   my $self = shift;
#   my $resp = '';
#   foreach my $dir (@{ $self->{'directives'}} ) {
#     $resp .= $dir->gen_directive_document();
#   }
#   return $resp;
# }

sub gen_raw_document {
	my ($self, $r) = @_;
	my $logger = get_logger();
	my $eid = $self->{'eid'};
	my @directives = map {$_->to_directive($eid)} @{$self->{'directives'}};
	if (scalar @directives == 1) {
	  my $directive = $directives[0];
	  $logger->trace("Directive: ", sub {Dumper($directive)});
	  my $raw = $directive->{'options'};
	  my $status = $raw->{'status'};
	  $logger->trace("Status: ",sub {Dumper($status)});
	  my $headers = $raw->{'headers'};
	  my $content = $raw->{'content'};
	  my $content_type = $directive->{'name'};
	  $status = 'HTTP_OK' unless ($status); 
	  if ($status eq "HTTP_OK") {
	    	  $r->content_type($content_type);
	    	  for my $hkey (keys %{$headers}) {
    	      $r->headers_out->add($hkey => $headers->{$hkey});
    	      #$logger->debug("Header: $hkey Value: $headers->{$hkey}");
  	     }
	    	  	    
	  } else {
  	    for my $hkey (keys %{$headers}) {
  	      #$logger->debug("EHeader: $hkey EValue: $headers->{$hkey}");
  	      if ($hkey eq 'Location') {
  	        $r->headers_out->set($hkey => $headers->{$hkey});
  	      } else {
  	        $r->err_headers_out->add($hkey => $headers->{$hkey});
  	      }
  	      
  	    }
  	    
	    
	  }
	  if ($content) {
	    $r->print( $content);
	  }
	  
    $r->status(Apache2::Const->$status);
    return Apache2::Const::OK;
	} else {
	  $logger->warn("Multiple directives not implemented for send_raw");
	}
}

sub respond {
  my ($r, $req_info, $session, $js, $dd, $realm) = @_;

  my $logger = get_logger();


  # put this in the logging DB
  Kynetx::Log::log_rule_fire($r,
			     $req_info,
			     $session
			    );


  # finish up
  Kynetx::Session::session_cleanup($session,$req_info);

  # return the JS load to the client
  $logger->info("$realm processing finished");
  $logger->debug("__FLUSH__");

  $logger->trace("Called with ", $r->the_request);

  # heartbeat string (let's people know we returned something)
  my $heartbeat = "// KNS " . gmtime() . " (" . Kynetx::Util::get_hostname() . ")\n";

  # this is where we return the JS
  binmode(STDOUT, ":encoding(UTF-8)");
  if ($req_info->{'send_raw'}) {
    #$logger->debug("Returning raw directive");
    return $dd->gen_raw_document($r);
  }  elsif ($req_info->{'understands_javascript'}) {
    $logger->debug("Returning javascript from evaluation");
    if ($logger->is_debug()) {
      $logger->debug("__SCREEN__");
    }
    
    print $heartbeat, $js;
  } else {
    $logger->debug("Returning directives from evaluation");

    print $heartbeat, $dd->gen_directive_document();
  }

}

sub gen_raw_headers {
  my $self = shift;
}


1;
