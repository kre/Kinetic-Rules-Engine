package Kynetx::Predicates::Amazon::SNS::Response;
# file: Kynetx/Predicates/Amazon/SNS/Response.pm
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
use utf8;

use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);
use Exporter;
use Kynetx::Json qw(:all);
use Crypt::OpenSSL::X509;
use Crypt::OpenSSL::RSA;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;
use Data::Dumper;
use MIME::Base64;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    new
    dout
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

our $AUTOLOAD;

use constant USER_AGENT => 'Amazon Simple Notification Service Agent';
use constant PEM => 'https://sns.us-east-1.amazonaws.com/SimpleNotificationService.pem';

my $apk = eval {get_amazon_pub_key()};

my %fields = ();




sub new {
    my $class = shift;
    my $logger = get_logger();
    $logger->trace("Amazon pub key: ", $apk);
    my $self = {%fields};
    bless ($self,$class);
    my ($a_request) = @_;
    if (defined $a_request && ref $a_request eq 'Apache2::RequestRec') {
        $logger->trace("Received: ", ref $a_request);
        $self->_get_header_info($a_request);
        if ($self->{'_headers'}->{'User_Agent'} ne USER_AGENT) {
            $logger->warn("Not an SNS response: ",$self->{'_headers'}->{'User_Agent'});
            return undef;
        }
        $self->_get_content($a_request);
        $self->_validate();
    } else {
        $logger->warn("Usage: ",ref $self, "->new(Apache2::RequestRec)")
    }
    return $self;
}

sub _get_content {
    my $self = shift;
    my $logger = get_logger();
    my $r = shift;
    my $data;
    if (defined $self->{'_headers'}) {
        my $headers = $self->{'_headers'};
        my $uagent = $headers->{'Content_Type'};
        my $len = $headers->{'Content_Length'};
        if ($len > 0) {
            $r->read($data,$len);
            $self->{'_body'} = $data;
            my $ctype = $headers->{'Content_Type'};
            if ($ctype =~ m/text.plain/i) {
                # try to create JSON
                my $json = Kynetx::Json::jsonToAst_w($data);
                $self->{'content'} = $json;
                if (ref $json eq 'HASH') {
                    $self->{'response_type'} = $json->{'Type'};
                }
            }
        } else {
            $logger->warn("Empty content in ", caller());
        }
    } else {
        $logger->warn("No headers defined for ", caller());
    }

}

sub _get_header_info {
    my $self = shift;
    my $logger = get_logger();
    my ($r) = @_;
    my $headers = $r->headers_in();
    foreach my $key (keys %{$headers}) {
        $logger->trace("k: ", $key, " v: ", $headers->{$key});
        my $pkey = $key;
        $pkey =~ s/-/_/g;
        $self->{'_headers'}->{$pkey} = $headers->{$key};
    }
}

sub AUTOLOAD {
    my $self   = shift;
    my $logger = get_logger();
    my $type   = ref($self)
      or warn "($AUTOLOAD): $self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

sub DESTROY { }
sub dout {
    my $self = shift;
    my $str="";
    foreach my $key (keys %fields) {
        if ($self->{$key}) {
            $str.="$key => ".$self->{$key}."\n";
        }
    }
    return $str;
}

sub _validate {
    my $self = shift;
    my $sns_content = $self->{'content'};
    my $logger = get_logger();
    $logger->trace("validate: ", sub {Dumper($self)});
    my $verified = 0;
    my $cstr = _get_canonical_data_string($sns_content);
    my $b64signature = $sns_content->{'Signature'};
    $logger->trace("b64 Sig: ", $b64signature);
    my $sig = decode_base64($b64signature);
    if ($cstr) {
        my $rsa_pubkey = Crypt::OpenSSL::RSA->new_public_key($apk);
        $logger->trace("Message: ", $cstr);
        $logger->trace("Sig: ", $sig);
        $verified = $rsa_pubkey->verify($cstr,$sig);
    }
    $self->{'_meta'}->{'Signature_verified'} = $verified;

}

sub _get_canonical_data_string {
    my $self = shift;
    my $logger = get_logger();
    if ($self->{'Type'} eq 'Notification') {
        my $cmsg = "Message\n";
        $cmsg .= $self->{'Message'} . "\n";
        $cmsg .= "MessageId\n";
        $cmsg .= $self->{'MessageId'} ."\n";
        if ($self->{'Subject'}) {
            $cmsg .= "Subject\n";
            $cmsg .= $self->{'Subject'} . "\n";
        }
        $cmsg .= "Timestamp\n";
        $cmsg .= $self->{'Timestamp'} . "\n";
        $cmsg .= "TopicArn\n";
        $cmsg .= $self->{'TopicArn'} . "\n";
        $cmsg .= "Type\nNotification\n";
        return $cmsg;
    }

}

sub get_amazon_pub_key {
    my $hreq = HTTP::Request->new(GET => PEM);
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->request($hreq);
    my $pem = $resp->content;
    my $x509 = Crypt::OpenSSL::X509->new_from_string($pem);
    my $rsa_pub_str = $x509->pubkey();
    return $rsa_pub_str;
}

sub verify {
    my $self = shift;
    if ($self->{'_meta'}->{'Signature_verified'}) {
        return $self->{'_meta'}->{'Signature_verified'};
    } else {
        return undef;
    }
}


1;
