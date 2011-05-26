package Kynetx::Predicates::Amazon;

# file: Kynetx/Predicates/Amazon.pm
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

use Log::Log4perl qw(get_logger :levels);

use Apache2::Const;
use YAML::XS;
use URI::Escape qw(uri_escape_utf8);
use Data::Dumper;

use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Errors;
use Kynetx::Configure qw/:all/;
use Kynetx::JSONPath qw/:all/;
use Kynetx::Predicates::Amazon::RequestSignatureHelper;
use Kynetx::Predicates::Amazon::ItemSearch;
use Kynetx::Predicates::Amazon::ItemLookup;
#use Kynetx::Predicates::Amazon::Widget;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
        search
        get_parameters
        )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} });

use constant DEFAULT_LOCALE =>  'us';
use constant LOCALE => 'us';

my %predicates = (
    # search predicates

);

my $actions = {

};

sub get_actions {
    return $actions;
}


sub get_endpoint {
    my ($locale) = @_;
    my $logger = get_logger();
    my $endpoint;
    my $amazon_config = Kynetx::Configure::get_config('LOCALE','AMAZON');
    if (defined $amazon_config->{$locale}->{'endpoint'}) {
        $endpoint = $amazon_config->{$locale}->{'endpoint'};
    } else {
        $endpoint = $amazon_config->{DEFAULT_LOCALE}->{'endpoint'}
    }
    $logger->trace("Enpoint: ", $endpoint);
    return $endpoint;
}

sub get_predicates {
    return \%predicates;
}

sub eval_amazon {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $built;
    my $a_request;
    my $a_response;
    my $a_args;
    my $endpoint;
    my $logger = get_logger();
    if (ref $args eq 'ARRAY' && int($args)>0) {
        foreach my $arg (@$args) {
            if (ref $arg eq 'HASH') {
                $a_args = $arg;
                last;
            }
        }
    } else {
        $logger->debug("function args not passed as array",sub {Dumper($args)});
    }
    my $locale = get_locale($a_args);
    $logger->debug( "amazon function -> ", $function );
    $logger->trace( "search: req:", sub { Dumper($req_info) } );
    my $secret = get_amazon_tokens($req_info,$rule_env);
    $a_request->{'Service'} = 'AWSECommerceService';
    $a_request->{'Version'} = '2010-09-01';

    if ($function eq 'item_search') {
        $built = Kynetx::Predicates::Amazon::ItemSearch::build($a_request,$a_args,$locale);
    } elsif ($function eq 'item_lookup') {
        $built = Kynetx::Predicates::Amazon::ItemLookup::build($a_request,$a_args,$locale);
    } elsif ($function eq 'widget') {
        #my $widget = Kynetx::Predicates::Amazon::Widget::build($a_request,$args,$locale,$secret->{'associate_id'});
        #$logger->trace("Widget: ", $widget);
        #return $widget;
        return '';
    }

    if (Kynetx::Errors::mis_error($built)) {
        Kynetx::Errors::merror($built,"Unable to build Amazon request (".$function.")");
        $logger->warn("Poorly formed request: ", sub {Dumper($args)});
        $logger->debug("fail: ", $built->{'DEBUG'} || '');
        $logger->trace("fail detail: ", $built->{'TRACE'} || '');
        return [];
    }

    $logger->trace("send this query: ", sub {Dumper($a_request)});
    $a_response = request($locale,$secret,$a_request);
}


sub get_amazon_tokens {
    my ($req_info, $rule_env) = @_;
    my $amazon_tokens;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    unless ( $amazon_tokens = Kynetx::Keys::get_key($req_info, $rule_env, 'amazon')  ) {
        my $ruleset =
          Kynetx::Repository::get_rules_from_repository( $rid, $req_info );

#        $logger->debug("Got ruleset: ", Dumper $ruleset);
        $amazon_tokens = $ruleset->{'meta'}->{'keys'}->{'amazon'};
	Kynetx::Keys::insert_key($req_info, $rule_env, 'amazon', $amazon_tokens);

    }
    return $amazon_tokens;

}

sub request {
    my ($locale,$secret,$request)=@_;
    my $content;
    my $logger = get_logger();
    my $endpoint = get_endpoint($locale);
    if (Kynetx::Errors::mis_error($endpoint)) {
        return Kynetx::Errors::merror($endpoint,"Can't build request with bad endpoint",1);
    }
    my $memcached_key = get_request_key($request);
    $logger->trace("Secret: ", sub {Dumper($secret)});
    my $helper = new Kynetx::Predicates::Amazon::RequestSignatureHelper(
        'AWSAccessKeyId' => $secret->{'token'},
        'AWSSecretKey' => $secret->{'secret_key'},
        'EndPoint' => $endpoint,
    );

    # Sign the request
    my $signedRequest = $helper->sign($request);

    # We can use the helper's canonicalize() function to construct the query string too.
    my $queryString = $helper->canonicalize($signedRequest);
    my $url = "http://" . $endpoint . "/onca/xml?" . $queryString;
    $logger->debug("Sending request to URL: $url");

    $content = Kynetx::Memcached::get_remote_data($url,120,$memcached_key);
    my $converted = Kynetx::Json::xmlToJson($content);
    Kynetx::Json::collapse($converted);
    return $converted;
}

#  stolen from RequestSignatureHelp::canonicalize()
sub get_request_key {
    my ($request_hash) = @_;
    my @parts = ();

    while (my ($k, $v) = each %$request_hash) {
        my $x = escape($k) . "=" . escape($v);
        push @parts, $x;
    }

    my $out = join ("&", sort @parts);
    return $out;

}

# stolen from RequestSignatureHelp::escape
sub escape {
    my ($stmt) = @_;
    return uri_escape_utf8($stmt,'^A-Za-z0-9\-_.~');
}

sub get_locale{
    my ($args) = @_;
    my $amazon_config = Kynetx::Configure::get_config('LOCALE','AMAZON');
    my $logger = get_logger();
    $logger->trace("get_locale: ", ref $args, " ",sub {Dumper($args)});
    my $locale;
    if (! defined $args->{'locale'}) {
        $locale = DEFAULT_LOCALE;
    } elsif (! defined $amazon_config->{$args->{'locale'}}){
        $locale = DEFAULT_LOCALE;
    } else {
        $locale = $args->{'locale'};
    }
    return $locale;
}

# Convenience functions
sub jsonlookup {
    my ($struct,$pattern) = @_;
    my $jp = Kynetx::JSONPath->new();
    my $result = $jp->run($struct,$pattern);
    if ($result) {
        return $result;
    } else {
        return '';
    }
}
sub good_response {
    my ($amz_response) = @_;
    my $logger = get_logger();
    my $result='';
    my $pattern = '$..Items.Request.IsValid';
    $result = jsonlookup($amz_response,$pattern);
    $logger->trace("json result: ",sub {Dumper($result)});
    if (ref $amz_response ne 'HASH') {
        return 0;
    }
    if (! defined $result) {
        return 0;
    }elsif( $result->[0] eq "True") {
        return 1;
    } else {
        return 0;
    }
}

sub get_error_msg {
    my ($amz_response) = @_;
    my $pattern = '$..Errors.Error';
    my $result = jsonlookup($amz_response,$pattern);
    return $result;
}

sub get_request_args {
    my ($amz_response) = @_;
    my $pattern = '$..ItemSearchRequest';
    my $result = jsonlookup($amz_response,$pattern);
    return $result;

}

sub total_items {
    my ($amz_response) = @_;
    my $pattern = '$..TotalResults';
    my $result = jsonlookup($amz_response,$pattern);
    return $result->[0];

}

sub total_pages {
    my ($amz_response) = @_;
    my $pattern = '$..TotalPages';
    my $result = jsonlookup($amz_response,$pattern);
    return $result->[0];

}

sub get_ASIN {
    my ($amz_response) = @_;
    my $pattern = '$..ASIN';
    my $result = jsonlookup($amz_response,$pattern);
    return $result;

}


1;
