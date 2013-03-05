package Kynetx::Endpoints::KNS;
# file: Kynetx/Endpoints/KNS.pm
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
#use warnings;
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
                        my $version = $ast->{'options'}->{'version'} || Kynetx::Rids::version_default();
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
