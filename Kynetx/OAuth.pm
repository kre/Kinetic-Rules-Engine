package Kynetx::OAuth;
# file: Kynetx/OAuth.pm
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

my ($namespace,$req_info,$session,$rid, $rule_env);

sub new {
  my $class  = shift;
  my ($ns, $ri, $re, $sess, $urls) = @_;

  my $logger = get_logger();

  $namespace = $ns;
  $req_info = $ri;
  $session = $sess;
  $rule_env = $re;
  

  $rid = $req_info->{'rid'};

#  my $tokens = session_get($rid, $session, $namespace.':access_tokens');
  my $tokens = get_access_tokens();

  $logger->debug("Tokens: ", sub { Dumper $tokens});

  if (defined $tokens &&
      defined $tokens->{'access_token'} &&
      defined $tokens->{'access_token_secret'}) {

    $logger->debug("Using access_token = " . $tokens->{'access_token'} .
		   " &  access_secret = " . $tokens->{'access_token_secret'} );

    my $consumer_tokens = get_consumer_tokens($req_info, $rule_env, $session, $namespace);

    $tokens->{'consumer_secret'} =     $consumer_tokens->{'consumer_secret'};
    $tokens->{'consumer_key'} =     $consumer_tokens->{'consumer_key'};



  } else {
      $tokens = get_consumer_tokens($req_info, $rule_env, $session, $namespace);
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
  my ( $req_info, $rule_env, $session, $namespace ) = @_;
  my $consumer_tokens;
  my $logger = get_logger();
  unless ($consumer_tokens = Kynetx::Keys::get_key($req_info, $rule_env, $namespace) ) {
    my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $req_info);
#    $logger->debug("Got ruleset: ", Dumper $ruleset);
    $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{$namespace};
    Kynetx::Keys::insert_key($req_info, $rule_env, $namespace, $consumer_tokens);

  }
#  $logger->debug(Dumper $consumer_tokens);
  return $consumer_tokens;
}

sub store_access_tokens {
  my $self         = shift;
  my ($tokens) = @_;

  my $logger = get_logger();

  my $foo = Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $namespace.':access_tokens', $tokens);

#  $logger->debug("Session after store: ", sub { Dumper $session});

}

sub get_access_tokens {
#  my $self         = shift;

  session_get($rid, $session, $namespace.':access_tokens');
}


sub store_request_secret {
  my $self         = shift;
  my ($secret) = @_;

  Kynetx::Persistence::save_persistent_var("ent",$rid, $session, $namespace.':token_secret', $secret);


}

sub set_token_secret {
  my $self         = shift;

  $self->request_token_secret(session_get($rid, $session, $namespace.':token_secret'));
}


1;
