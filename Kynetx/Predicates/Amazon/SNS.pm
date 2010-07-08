package Kynetx::Predicates::Amazon::SNS;
# file: Kynetx/Predicates/Amazon/SNS.pm
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

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Exporter;
use Kynetx::Json qw(:all);

use Kynetx::Predicates::Amazon::RequestSignatureHelper qw(
    kAWSAccessKeyId
    kAWSSecretKey
    kEndPoint
    kRequestMethod
    kRequestUri
    kSignatureParam
    kSignatureVersionParam
    kSignatureVersionValue
    kSignatureMethodParam
    kSignatureMethodValue
    kTimestampParam
);


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

my %fields = (
    'Subject' => undef,
    'TopicArn' => undef,
    'Message' => undef,
    'Action' => undef,
    'Protocol' => undef,
    'Endpoint' => undef,
    'NewTopicName' => undef,
    kSignatureVersionParam() => +kSignatureVersionValue,
    kSignatureMethodParam() => +kSignatureMethodValue,
    kAWSAccessKeyId() => undef,
    kAWSSecretKey() => undef,
    kEndPoint() => 'sns.us-east-1.amazonaws.com',
    kTimestampParam() => undef,
    kSignatureParam() => undef,
    kRequestUri() => "/",
);



sub new {
    my $class = shift;
    my $logger = get_logger();
    my $self = {%fields};
    bless ($self,$class);
    my ($var_hash) = @_;
    if (defined $var_hash and ref $var_hash eq 'HASH') {
        foreach my $varkey (keys %$var_hash) {
            if (exists $self->{$varkey}) {
                $self->{$varkey} = $var_hash->{$varkey};
            }
        }

    }
    return $self;
}

sub AUTOLOAD {
    my $self   = shift;
    my $logger = get_logger();
    my $type   = ref($self)
      or die "($AUTOLOAD): $self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    unless ( exists $self->{$name} ) {
        $logger->trace("$name not permitted in class $type");
        return;
    }

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

sub publish {
    my $self = shift;
    $self->{'Action'} = "Publish";

    my $logger = get_logger();
    my $params = {
        'Subject' => $self->{'Subject'},
        'TopicArn' => $self->{'TopicArn'},
        'Message' => $self->{'Message'},
        'Action' => $self->{'Action'}
    };
    my $resp = $self->_request($params);
}

sub subscribe {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = "Subscribe";
    my $params = {
        'TopicArn' => $self->{'TopicArn'},
        'Protocol' => $self->{'Protocol'},
        'Endpoint' => $self->{'Endpoint'},
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);

}

sub create_topic {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'CreateTopic';
    my $params = {
        'Name' => $self->{'NewTopicName'},
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);
}

sub delete_topic {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'DeleteTopic';
    my $params = {
        'TopicArn' => $self->{'TopicArn'},
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);
}

sub list_subscriptions {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'ListSubscriptions';
    my $params = {
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);

}

sub list_subscriptions_by_topic {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'ListSubscriptionsByTopic';
    my $params = {
        'TopicArn' => $self->{'TopicArn'},
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);


}

sub list_topics {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'ListTopics';
    my $params = {
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);

}

sub get_topic_attributes {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'get_topic_attributes';
    my $params = {
        'TopicArn' => $self->{'TopicArn'},
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);


}

sub unsubscribe {
    my $self = shift;
    my $logger = get_logger();
    $self->{'Action'} = 'Unsubscribe';
    my $params = {
        'SubscriptionArn' => $self->{'SubscriptionArn'},
        'Action' => $self->{'Action'},
    };
    my $resp = $self->_request($params);

}

sub set_topic_attributes {
    my $self = shift;
    my $logger = get_logger();
    $logger->trace("passed raw: ", sub {Dumper($_)});
    my ($attr_hash) = @_;
    $self->{'Action'} = 'SetTopicAttributes';
    my $params = {
        'TopicArn' => $self->{'TopicArn'},
        'Action' => $self->{'Action'},
    };
    $logger->trace("Passed: ",ref $attr_hash);
    if (ref $attr_hash eq 'HASH') {
        my ($key,$value) = each %$attr_hash;
        $params->{'AttributeName'} = $key;
        $params->{'AttributeValue'} = $value;
    }
    my $resp = $self->_request($params);
}


sub _request {
    my $self = shift;
    my ($params) = @_;
    my $logger = get_logger();
    my $helper = new Kynetx::Predicates::Amazon::RequestSignatureHelper(%$self);
    my $signed_param = $helper->sign($params);
    my $canonical = $helper->canonicalize($signed_param);
    my $url = "http://" . $self->{kEndPoint()} ."/?$canonical";
    $logger->debug("URL: ",$url);
    my $hreq = HTTP::Request->new(GET => $url);
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->request($hreq);
    if ($resp->is_error) {
        $logger->warn("SNS request error: (",$resp->code,") ",$resp->status_line);
        return undef;
    }
    if ($resp->is_success) {
        $logger->trace("SNS ",$self->{'Action'}, " to ARN: ",$self->{'TopicArn'});
        $logger->trace("Response: ", sub {Dumper($resp)});
        my $json = Kynetx::Json::xmlToJson($resp->content);
        Kynetx::Json::collapse($json);
        return $json;
    }


}

