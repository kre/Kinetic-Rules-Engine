package Kynetx::Predicates::Amazon::SNS;
# file: Kynetx/Predicates/Amazon/SNS.pm
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
use utf8;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Exporter;
use Kynetx::Json qw(:all);
use Encode;
#use Encoding::BER::DER;

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


# Supports changing the DisplayName attribute
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

