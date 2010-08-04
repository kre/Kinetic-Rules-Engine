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
use Kynetx::Util;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;
use Kynetx::Memcached qw(
        get_memd
);
use Cache::Memcached qw(
    flush_all
    delete
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

my $funcs = {};

sub confirm_subscription {
    my ($sns,$rids) = @_;
    my $logger = get_logger();
    my $url = $sns->content->{'SubscribeURL'};
    $logger->trace("URL: **", $url,"**");
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->request(GET $url);
    $logger->debug("Response: ", sub {Dumper($resp)});
    if ($resp->is_success()) {
        $logger->info("Subscription verified for $url");
    } else {
        $logger->warn("Unable to confirm subscription request for $url");
    }

}
$funcs->{'SubscriptionConfirmation'} = \&confirm_subscription;

sub notification {
    my ($sns,$rids) = @_;
    my $logger = get_logger();
    $logger->trace("SNS object: ", sub {Dumper($sns)});
    my $topic = $sns->content->{'TopicArn'};
    my $msg_id = $sns->content->{'MessageId'};
    $logger->info("Received SNS notification ($msg_id) from $topic");
    my $message = $sns->content->{'Message'};
    my $verified = $sns->_meta->{'Signature_verified'};
    if ($verified) {
        parse_message($message);
    } else {
        $logger->warn("Unable to verify signature of $msg_id");
    }


}
$funcs->{'Notification'} = \&notification;

sub parse_message {
    my ($msg) = @_;
    my $logger = get_logger();
    my $ast = Kynetx::Json::jsonToAst_w($msg);
    $logger->debug("Directive: ", sub {Dumper($ast)});
    if (ref $ast eq 'HASH') {
        if ($ast->{'name'} eq 'kns') {
            my $rid;
            my $action;
            my $log = "SNS Handler received unmatched notification: $msg";
            if ($ast->{'options'}) {
               $action = $ast->{'options'}->{'action'};
               if ($ast->{'meta'}) {
                   $rid = $ast->{'meta'}->{'rid'};
               }
               if ($action eq 'flush') {
                   my $memd = get_memd();
                   if ($rid) {
                        my $version = $ast->{'options'}->{'version'} || 'prod';
                        $log = "[SNS request] flushing rules for $rid ($version version)";
                        my $cache_key = Kynetx::Repository::make_ruleset_key($rid, $version);
                        $logger->debug("key: $cache_key");
                        my $result = $memd->delete($cache_key);

                   } else {
                       $log = "[SNS request] Flush cache";
                       $memd->flush_all;
                   }

               } elsif ($action eq 'stats') {
                   my $memd = get_memd();
                   $Data::Dumper::Terse = 1;
                   $log = "Cache stats: " .Dumper($memd->stats('misc'));
               } elsif ($action eq 'count') {
                   my $memd = get_memd();
                   my $stats = $memd->stats('misc');
                   $Data::Dumper::Terse = 1;
                   $log= "Cache item count: " . Dumper($stats->{'total'}->{'curr_items'});
               }
            }
            Kynetx::Util::bloviate($log);

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
