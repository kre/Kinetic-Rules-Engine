package Kynetx::Predicates::Amazon::RequestSignatureHelper;
##############################################################################################
# Copyright 2009 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file 
# except in compliance with the License. A copy of the License is located at
#
#       http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under the License. 
#
# ############################################################################################
#
#  Amazon Product Advertising API
#  Signed Requests Sample Code
#
#  API Version: 2009-03-31
#
#############################################################################################

use strict;
use warnings;
use utf8;

use Data::Dumper;

use Digest;
use Digest::SHA qw(hmac_sha256_base64);
use URI::Escape qw(uri_escape_utf8);

# set this to 1 if you want to see debugging output, 0 otherwise.
my $DEBUG = 0;

use base 'Exporter';
our @EXPORT = qw(kAWSAccessKeyId kAWSSecretKey kEndPoint kRequestMethod kRequestUri);

use constant kAWSAccessKeyId => 'AWSAccessKeyId';
use constant kAWSSecretKey   => 'AWSSecretKey';
use constant kEndPoint       => 'EndPoint';
use constant kRequestMethod  => 'RequestMethod';
use constant kRequestUri     => 'RequestUri';

use constant kTimestampParam        => 'Timestamp';
use constant kSignatureParam        => 'Signature';
use constant kSignatureVersionParam => 'SignatureVersion';
use constant kSignatureVersionValue => '2';
use constant kSignatureMethodParam  => 'SignatureMethod';
use constant kSignatureMethodValue  => 'HmacSHA256';

# The docs are very clear about what should be escaped and what shouldn't.
# So we use this regex with uri_escape to ensure only the right characters are
# escaped
use constant kUriEscapeRegex => '^A-Za-z0-9\-_.~';

sub new {
    my ($class, %args) = @_;
    debug ("instantiating class \"$class\" with args: " . Dumper(\%args));
    
    my $self = {};
    
    die 'Need AWSAccessKeyId argument' unless exists $args{+kAWSAccessKeyId};
    die 'Need AWSSecretKey argument' unless exists $args{+kAWSSecretKey};
    die 'Need EndPoint argument' unless exists $args{+kEndPoint};
    
    for (+kAWSAccessKeyId, +kAWSSecretKey, +kRequestMethod, +kRequestUri) { 
    $self->{$_} = $args{$_} 
    };

    # end-point must be in lowercase
    $self->{+kEndPoint}     = lc($args{+kEndPoint});

    # request-method defaults to GET if not provided. 
    $self->{+kRequestMethod}    = 'GET' unless defined $self->{+kRequestMethod};

    # request-uri defaults to /onca/xml if not provided. 
    $self->{+kRequestUri}   = '/onca/xml' unless defined $self->{+kRequestUri};

    bless $self, $class;

    debug ("constructed \"$class\" instance: " . Dumper($self));
    return $self;
}

# Call this method to sign the request. The request should be in the form
# for a hash map of parameter name-value pairs.
sub sign {
    my ($self, $params) = @_;
    debug ("signing request: " . Dumper($params));
    
    # add the AWSAccessKeyId to the request, in case it's not already set correctly.
    $params->{+kAWSAccessKeyId} = $self->{+kAWSAccessKeyId};

    # add a Timestamp to the request, in case it's not already set.
    $params->{+kTimestampParam} = $self->generateTimestamp() unless exists $params->{+kTimestampParam};

    # SignatureVersion and SignatureMethod are optional for us, since we use the default values anyway.
    # $params->{+kSignatureVersionParam} = +kSignatureVersionValue;
    # $params->{+kSignatureMethodParam} = +kSignatureMethodValue;
    debug ("extended request: " . Dumper($params));

    # get the canonical form of the query string
    my $canonical = $self->canonicalize($params);
    debug ("canonical form: \"$canonical\"\n");

    # construct the data to be signed as specified in the docs
    my $stringToSign = 
    $self->{+kRequestMethod}    . "\n" . 
    $self->{+kEndPoint}     . "\n" . 
    $self->{+kRequestUri}       . "\n" . 
    $canonical;
    debug ("string to sign: \"$stringToSign\"\n");
    
    # calculate the signature value and add it to the request.
    my $signature = $self->digest($stringToSign);
    $params->{+kSignatureParam} = $signature;

    debug ("signature: \"$signature\"\n");
    debug ("final signed request: " . Dumper($params));
    
    return $params;
}

# The Timestamp must be generated in a specific format.
sub generateTimestamp {
    return sprintf("%04d-%02d-%02dT%02d:%02d:%02d.000Z",
       sub {    ($_[5]+1900,
                 $_[4]+1,
                 $_[3],
                 $_[2],
                 $_[1],
                 $_[0])
           }->(gmtime(time)));
}

# URI escape only the characters that should be escaped, according to RFC 3986
sub escape {
    my ($self, $x) = @_;
    return uri_escape_utf8($x, +kUriEscapeRegex);
}

# The digest is the signature
sub digest {
    my ($self, $x) = @_;
    my $digest = hmac_sha256_base64 ($x, $self->{+kAWSSecretKey});

    # Digest::MMM modules do not pad their base64 output, so we do
    # it ourselves to keep the service happy. 
    return $digest . "=";
}

# Constructs the canonical form of the query string as specified in the docs.
sub canonicalize {
    my ($self, $params) = @_;
    
    my @parts = ();
    while (my ($k, $v) = each %$params) {
    my $x = $self->escape($k) . "=" . $self->escape($v);
    push @parts, $x;
    }

    my $out = join ("&", sort @parts);
    return $out;
}

sub debug {
    if ($DEBUG) { print STDERR shift }
}

1;

