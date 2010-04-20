package Kynetx::OAuth;
# file: Kynetx/OAuth.pm
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

#use base qw(Net::OAuth::Simple);
use Net::OAuth::Simple;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use LWP::UserAgent;
use HTTP::Request::Common;

use Kynetx::Session qw/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;

# we inherit from Net::OAuth::Simple.  
our @ISA         = qw(Exporter Net::OAuth::Simple);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
 qw(
 ) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

#our $AUTOLOAD;

#
# $namespace is the name the Parser assigns to keys in the keys from the meta block
#

my ($namespace,$req_info,$session,$rid);

sub new {
  my $class  = shift;
  my ($ns, $ri, $sess, $urls) = @_;

  my $logger = get_logger();

  $namespace = $ns;
  $req_info = $ri;
  $session = $sess;
  
  $rid = $req_info->{'rid'};

#  my $tokens = session_get($rid, $session, $namespace.':access_tokens');
  my $tokens = get_access_tokens();

  $logger->debug("Tokens: ", sub { Dumper $tokens});

  if (defined $tokens && 
      defined $tokens->{'access_token'} &&
      defined $tokens->{'access_token_secret'}) {

    $logger->debug("Using access_token = " . $tokens->{'access_token'} . 
		   " &  access_secret = " . $tokens->{'access_token_secret'} );

    my $consumer_tokens = get_consumer_tokens();
    
    $tokens->{'consumer_secret'} =     $consumer_tokens->{'consumer_secret'};
    $tokens->{'consumer_key'} =     $consumer_tokens->{'consumer_key'};



  } else {
      $tokens = get_consumer_tokens();
      $logger->debug("Consumer tokens: ", sub{ Dumper $tokens});
  }

#  $logger->debug("Args:", Dumper [$ns,$ri,$sess,$urls]);

  $class->SUPER::new(tokens => $tokens, 
		     protocol_version => '1.0a',
		     urls   => $urls);
}

sub get_restricted_resource {
  my $self = shift;
  my $url  = shift;
  return $self->make_restricted_request($url, 'GET');
}

sub update_restricted_resource {
  my $self         = shift;
  my $url          = shift;
  my %extra_params = @_;
  return $self->make_restricted_request($url, 'POST', %extra_params);    
}

sub get_consumer_tokens {
  my $consumer_tokens;
  my $logger = get_logger();
  unless ($consumer_tokens = $req_info->{$rid.':key:'.$namespace}) {
    my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $req_info);
#    $logger->debug("Got ruleset: ", Dumper $ruleset);
    $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{$namespace};
  }
#  $logger->debug(Dumper $consumer_tokens);
  return $consumer_tokens;
}

sub store_access_tokens {
  my $self         = shift;
  my ($tokens) = @_;

  my $logger = get_logger();
 
  my $foo = session_store($rid, $session, $namespace.':access_tokens', $tokens);

#  $logger->debug("Session after store: ", sub { Dumper $session});
 
}

sub get_access_tokens {
#  my $self         = shift;

  session_get($rid, $session, $namespace.':access_tokens');
}


sub store_request_secret {
  my $self         = shift;
  my ($secret) = @_;

  session_store($rid, $session, $namespace.':token_secret', $secret);


}

sub set_token_secret {
  my $self         = shift;

  $self->request_token_secret(session_get($rid, $session, $namespace.':token_secret'));
}


1;
