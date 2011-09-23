package Kynetx::Modules::Email;

# file: Kynetx/Modules/Email.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Email::MIME qw/:all/;
use Email::MIME::ContentType;
use MIME::QuotedPrint::Perl;
use Encode;
use Encode::Alias;
use MIME::Base64;

use Kynetx::Environments qw/:all/;
use Kynetx::Errors;

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
    my @parry  = ();
    foreach my $p (@parts) {
        my $value = "";
        my $key = $p->{'ct'}->{'discrete'} . '/' . $p->{'ct'}->{'composite'};
        eval {$value = $p->body_str()};
        if ($@) {
            my $partheaders = $p->{'header'}->{'headers'};
            my %found;
            map {$found{$_} = 1 } @$partheaders;
            $value = $p->body_raw();
            if ($p->content_type) {
                my $ct = parse_content_type($p->content_type);
                $logger->debug("Content type: ", sub {Dumper($p->content_type)});
                my $charset = $ct->{'attributes'}{'charset'};
                if ($charset) {
                    $value = Encode::decode($charset,$value);
                }
            }
            if ($found{'quoted-printable'}) {
                $value = MIME::QuotedPrint::Perl::decode_qp($value);
            }

            if ($found{'base64'}) {
                $value =  decode_base64($value);
            }

            if (ref $value eq 'SCALAR') {
                $value = $$value;
            }
        }
        push( @parry, { $key => $value } ) unless ($parms && $key ne $parms);
    }
    return \@parry;
}
$funcs->{"parts"} = \&_parts;

sub _body {
    my ( $req_info, $rule_env, $args ) = @_;
    define_alias(qr/7bit/ => '"us-ascii"');
    my $logger = get_logger();
    my $email  = email_object($args);
    my $value="";
    eval {$value = $email->body_str()};
    if ($@) {
        my $encoding = $email->header("Content-Transfer-Encoding");
        if ($encoding) {
            $logger->debug("Using encoding: $encoding");
            return decode($encoding,$email->body_raw());
        } else {
            $logger->debug("No encoding: perhaps email is multipart");
            my $body = $email->body();
            $body = $email->body_raw() unless ($body);
            return $body;
        }
    } elsif ($value) {
        return $value;
    } else {
        return $email->body();
    }


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
    # Suppress warnings on "text/plain;"
    $Email::MIME::ContentType::STRICT_PARAMS=0;
    my $f = $funcs->{$function};
    if ( defined $f ) {
        my $result = $f->( $req_info, $function, $args );
        if ( Kynetx::Errors::mis_error($result) ) {
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
