##################################################
package Log::Log4perl::Appender::ErrorStack;
##################################################

our @ISA = qw(Log::Log4perl::Appender);

#use warnings;
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

use LWP::UserAgent;
use JSON::XS;
use Data::Dumper;

use Log::Log4perl::Level;


##################################################
sub new {
##################################################
    my($class, @options) = @_;

    my $self = {
        name   => "unknown name",
	base_url => "http://www.errorstack.com/submit",
	key => "",
	type => 'json',
	level => $WARN,
	trigger => \&truth, # always flush if no trigger defn
	buffer => [],
        @options,
    };

    bless $self, $class;
}
    
##################################################
sub log {
##################################################
    my ($self, %params) = @_;


#    warn Dumper %params;

    if (Log::Log4perl::Level::to_priority($params{'log4p_level'}) >=
	Log::Log4perl::Level::to_priority($self->{'level'})) {
      push(@{$self->{'buffer'}}, \%params);
    }

    
    # flush then the trigger function is true and there's something to flush
    $self->flush() if int(@{$self->{'buffer'}}) > 0 &&
                      $self->{trigger}->($self, \%params);


}

sub flush {
  my $self = shift;

  my $m = {'_s' => $self->{'key'},
	   '_r' => $self->{'type'},
	   'message' => [],
	   'category' => []};

  my $i = 0;

  foreach my $p (@{ $self->{'buffer'} }) {
    push(@{$m->{'message'}}, $p->{'message'});
  }

  $m->{'message'} = join("<br/>", @{$m->{'message'}});
  
  my $url = $self->{'base_url'};

#  warn "Posting ", Dumper $m;
  my $browser = LWP::UserAgent->new;
    
  my $response = $browser->post( $url,  $m);

  if (! $response->is_success) {
  	warn "Bad response from ErrorStack server", $response->status_line;
  } else {
	  if ($self->{'type'} eq 'json') {
	    my $r = decode_json($response->content);
	    if (! $r->{'success'}) {
	      warn "Problem with ErrorStack logging event ", $r->{'errorMsg'}	
	    } else {
	      $self->{'buffer'} = [];
	    }
	  } else {
	    $self->{'buffer'} = [];
	  }  	
  }


}

sub priority() {
  my ($self, $params) = @_;

  return Log::Log4perl::Level::to_priority($params->{'log4p_level'}) >=
    Log::Log4perl::Level::to_priority($self->{'level'});
}

sub truth() {
  my ($self, $params) = @_;

  return 1;
}

sub flush_message() {
  my ($self, $params) = @_;
#  warn "Checking ", Dumper $params;
  return $params->{'message'} =~ /__FLUSH__/;

}

1;

__END__

=head1 NAME

Log::Log4perl::Appender::ErrorStack - Log to ErrorStack

=head1 SYNOPSIS

    use Log::Log4perl::Appender::ErrorStack;

    my $es_appender = Log::Log4perl::Appender->new(
	     "Log::Log4perl::Appender::ErrorStack",
             name => 'ErrorStackLogger',
             key => 'ffjsdkajdlasdiaoijadada',
             level => 'DEBUG',
             trigger => sub { return 1 };
    );

    $logger->warn("Log me");

=head1 DESCRIPTION

This is a simple appender for writing to ErrorStack (http://www.errorstack.com)


The constructor C<new()> take a parameter C<key>, that is the stack key you 
get from ErrorStack.com.  Anything you want logged us given as a hash to log call.  
These will turned into URL QUERY string parameters for the call to ErrorStack.  

The constructor also takes an optional parameter C<level> that is the Log4perl level 
below which no logging will happen.

The constructor also takes an optional parameter C<trigger> that is a function that 
is used to determine when the log buffer will be flushed to ErrorStack.  The default
is to flush on every log message.  For infrequent logging this is acceptable.  For
frequent logging, it is preferable to define a trigger function that flushes the 
buffer on some event to limit the number of HTTP calls to ErrorStack. 

=head1 AUTHOR

Phil Windley <pjw@kynetx.com>, 2010

=cut
