package Kynetx::Modules::Email;

# file: Kynetx/Modules/Email.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Email::MIME qw/:all/;

use Kynetx::Environments qw/:all/;
use Kynetx::Util qw/
  mis_error
  merror
  /;

use Data::Dumper;
$Data::Dumper::Indent = 1;

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

my $predicates = {
    'multipart' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger    = get_logger();
        my $email     = email_object($args);
        my $num_parts = $email->parts();
        $logger->debug("Email has $num_parts pieces");
        return $num_parts > 0 ? 1 : 0;
    },

};

my $default_actions = {};

my $funcs = {};

sub _headers {
    my ( $req_info, $rule_env, $args ) = @_;
    my $logger = get_logger();
    my $email  = email_object($args);
    my $parms  = get_parms($args);
    if ($parms) {
        if ( ref $parms eq "ARRAY" ) {
            my $hash = {};
            foreach my $p (@$parms) {
                my $hval = $email->header($p);
                $hash->{$p} = $hval;
            }
            return $hash;
        } else {
            return $email->header($parms);
        }
    } else {
        my @keys = $email->header_names();
        return \@keys;
    }
    return 0;
}
$funcs->{"header"} = \&_headers;

sub _parts {
    my ( $req_info, $rule_env, $args ) = @_;
    my $logger = get_logger();
    my $email  = email_object($args);
    my $parms  = get_parms($args);
    my @parts  = $email->parts();
    $logger->debug("Parm: ", $parms);
    my @parry  = ();
    foreach my $p (@parts) {
        my $key = $p->{'ct'}->{'discrete'} . '/' . $p->{'ct'}->{'composite'};
        $logger->debug("Key: ", $key);
        push( @parry, { $key => $p->{'body'} } ) unless ($parms && $key ne $parms);
    }
    return \@parry;
}
$funcs->{"parts"} = \&_parts;

sub _body {
    my ( $req_info, $rule_env, $args ) = @_;
    my $logger = get_logger();
    my $email  = email_object($args);
    my $parms  = get_parms($args);
    my $body = $email->body();
    $logger->trace("Body val: **",$body,"**");
    $body = $email->body_raw() unless ($body);
    return $body;

}
$funcs->{"body"} = \&_body;

sub get_resources {
    return {};
}

sub get_actions {
    return $default_actions;
}

sub get_predicates {
    return $predicates;
}

sub email_object {
    my ($args) = @_;
    my $logger = get_logger();
    my $text;
    if ( ref $args eq "ARRAY" ) {
        $text = $args->[0];
    } else {
        $text = $args;
    }
    return Email::MIME->new($text);

}

sub get_parms {
    my ($args) = @_;
    if ( ref $args eq "ARRAY" ) {
        return $args->[1];
    } else {
        return undef;
    }
}

sub run_function {
    my ( $req_info, $function, $args ) = @_;

    my $logger = get_logger();

    #$logger->debug("Args passed: ", ref $args);
    my $f = $funcs->{$function};
    if ( defined $f ) {
        my $result = $f->( $req_info, $function, $args );
        if ( mis_error($result) ) {
            $logger->info("request email:$function failed");
            $logger->debug( "fail: ", $result->{'DEBUG'} || '' );
            $logger->trace( "fail detail: ", $result->{'TRACE'} || '' );
            return [];
        } else {
            return $result;
        }
    } else {
        $logger->debug("Function $function not defined");
    }
}

1;
