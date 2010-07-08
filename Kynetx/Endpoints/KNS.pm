package Kynetx::Endpoints::KNS;
# file: Kynetx/Endpoints/KNS.pm
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
use Data::Dumper;
use Exporter;
use Kynetx::Json qw(:all);
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;


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

my $funcs = {};

sub confirm_subscription {
    my ($sns,$rids) = @_;
    my $logger = get_logger();
    my $url = $sns->content->{'SubscribeURL'};
    $logger->debug("URL: **", $url,"**");
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->request(GET $url);
    $logger->debug("Response: ", sub {Dumper($resp)});

}
$funcs->{'SubscriptionConfirmation'} = \&confirm_subscription;

sub notification {
    my ($sns,$rids) = @_;
    my $logger = get_logger();
    my $topic = $sns->content->{'TopicArn'};
    my $msg_id = $sns->content->{'MessageId'};
    $logger->info("Received SNS notification ($msg_id) from $topic");
    my $message = $sns->content->{'Message'};
    parse_message($message);

}
$funcs->{'Notification'} = \&notification;

sub parse_message {
    my ($msg) = @_;
    my $logger = get_logger();
    my $ast = Kynetx::Json::jsonToAst_w($msg);
    $logger->trace("Directive: ", sub {Dumper($ast)});
    if (ref $ast eq 'HASH') {
        if ($ast->{'name'} eq 'kns') {
            my $rid;
            my $action;
            if ($ast->{'options'}) {
               $action = $ast->{'options'}->{'action'};
               if ($ast->{'meta'}) {
                   $rid = $ast->{'meta'}->{'rid'};
               }
               if ($action eq 'flush') {
                   if ($rid) {
                       $logger->info("Request to flush rule $rid");
                   } else {
                       $logger->info("Request to flush entire cache");
                   }

               }
            }

        }
    }
    $logger->warn("Invalid (SNS) directive");


}

sub eval_kns {
    my ($r,$endpoint,$medium,$rids) = @_;
    my $logger = get_logger();
    if ($medium eq 'sns') {
        $logger->debug("$endpoint/$medium");
        my $sns = Kynetx::Predicates::Amazon::SNS::Response->new($r);
        my $function = $sns->response_type();
        my $f = $funcs->{$function};
        if (defined $f) {
            my $result = $f->($sns,$rids);
        } else {
            my $str=caller();
            $logger->debug("Function $function not defined for KNS");
        }

    } else {
        $logger->warn("No endpoint defined for $endpoint/$medium");
    }

}

1;
