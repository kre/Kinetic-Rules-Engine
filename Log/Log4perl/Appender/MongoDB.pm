##################################################
package Log::Log4perl::Appender::MongoDB;
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
use lib qw( /web/lib/perl );

use MongoDB qw(:all);
use JSON::XS;
use Data::Dumper;
use Carp;


use Log::Log4perl::Level;
use constant COLLECTION => "devlog";
use constant MAXLOG => 10;
use constant TTL_INDEX => "expires";

our $MONGOp;

##################################################
sub new {
##################################################
  my($class, %options) = @_;
  my $self = {
    buffer => [],
    level => $DEBUG,
    mongo => undef,
    trigger => sub {return 0},
    trigger_level => undef,
    %options	
  };
  bless $self, $class;
  return $self;
}


sub get_mongo {
  my $self = shift;
  
  if ($self->{'mongo'}) {
    return $self->{'mongo'};
  }
  
  unless ($MONGOp) {
    my $server_string = $self->{'server'};
    my $port = $self->{'port'};
    
    my @hosts = split(",",$server_string);
    foreach my $host (@hosts) {
      eval {
			$MONGOp = MongoDB::Connection->new(host => $host,find_master =>1,query_timeout =>5000);
  		};
  		if ($@) {
  			#carp $@;
  		} else {
  			last;
  		}
    }
  }
  
  my $db = $self->{'db'};
  my $conn = $MONGOp->get_database($db);
  $self->{'mongo'} = $conn;
  return $self->{'mongo'};
}
    
##################################################
sub log {
##################################################
  my ($self, %params) = @_;
  my $msg = $params{'message'};
  
    
  if (Log::Log4perl::Level::to_priority($params{'log4p_level'}) >= $DEBUG) {
    push(@{$self->{'buffer'}},$msg);
  }
  
  $self->flush() if $self->{trigger}->($self, \%params);
  
}

##################################################
sub flush {
##################################################
  my $self = shift;
  my $eci = Log::Log4perl::MDC->get("_ECI_");
  my $text = join("", @{$self->{'buffer'}});
  $self->put($eci,$text);
  $self->{'buffer'} = [];  
}

###################################################
#sub DESTROY {
###################################################
#  my $self = shift;
#  if (Log::Log4perl::initialized()){
#    if (scalar @{$self->{'buffer'}} > 0) {
#      $self->flush();
#    }
#  }
#}

##################################################
sub put {
##################################################
  my $self = shift;
  my ($eci,$text) = @_;
  
  my $c = $self->get_collection();
  my $timestamp = DateTime->now->epoch;
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
  my $val = {
    'eci' => $eci,
    'text' => $text,
    'created'   => $timestamp,
    'maxlife' => DateTime->now,
    'ken' => $ken
  };
  my $id = $c->insert($val);
  $self->do_expire($eci);
}

sub do_expire {
  my $self = shift;
  my ($eci) = @_;
  
  # force constant to eval as string
  my $max = $self->{'maxlogs'} || MAXLOG;
  my $c = $self->get_collection();
  my $num = $self->count_logs($eci);
  #carp "$num of Max: $max ";
  if ($num > $max) {
    my $ttl = $self->{'ttl'} || TTL_INDEX . "";
    my $key = {'$and' => [{'eci' => $eci},{$ttl => {'$exists' => 0}}]};
    my $cursor = $c->query($key)->skip($max)->sort({'$natural' => 1});
    while (my $obj = $cursor->next) {
      my $oid = $obj->{'_id'}->to_string;
      $self->set_ttl($oid);
    }
  }
  
  
}

sub count_logs {
  my $self = shift;
  my ($eci) = @_;
  my $c = $self->get_collection();
  # force constant to eval as string
  my $ttl = $self->{'ttl'} || TTL_INDEX . "";
  my $key = {'$and' => [{'eci' => $eci},{$ttl => {'$exists' => 0}}]};
  my $count = $c->count($key);
  return $count;
}

sub get_collection {
  my $self = shift;
  my $m = $self->get_mongo();
  my $collection = $self->{'collection'} || COLLECTION;
  my $c = $m->get_collection($collection);
  return $c;
  
}

sub set_ttl {
  my $self = shift;
  my ($oid) = @_;
  my $c = $self->get_collection();
  my $ttl = $self->{'ttl'} || TTL_INDEX . "";
  my $id = MongoDB::OID->new(value => $oid);
	my $key = {
		"_id" => $id
	};
	my $val = {
	  '$set' => {$ttl => DateTime->now}
	};
	$c->update($key,$val);
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
