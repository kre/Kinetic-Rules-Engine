package Kynetx::Predicates::Google::Calendar;

# file: Kynetx/Predicates/Google/Calendar.pm
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

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Encode;
use LWP::UserAgent;
use HTTP::Request::Common;
use URI::Escape ('uri_escape');
#use XML::Atom::Entry;

use Kynetx::Session qw/:all/;
use Kynetx::Util qw(:all);
use Kynetx::Predicates::Google qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
        build
        build_post
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use constant SEP => ":";

my $tmp           = Kynetx::Configure::get_config('GOOGLE');
my $google_config = $tmp->{'google'};

sub build {
    my ($req_info,$rule_env,$args,$common,$http_method) = @_;
    my $logger = get_logger();
    $logger->trace( "common parms: ", sub { Dumper($common) } );
    my $full_parm = calendar_params($args,$common);
    $logger->trace( "common + calendar: ", sub { Dumper($full_parm) } );
    my $c_url = build_url($full_parm,$http_method);
    $logger->debug( "Google calendar url: ", $c_url );
    return $c_url;
}

sub calendar_params {
    my ($args, $google_params) = @_;
    my $logger        = get_logger();
    if ( !defined $google_config ) {
        $google_config = Kynetx::Configure::get_config('GOOGLE')->{'google'};
    }
    my $cparams      = $google_config->{'params'}->{'calendar'};
    $logger->trace("CALENDAR: ", sub {Dumper($google_params)});
    $google_params = Kynetx::Predicates::Google::get_params($args,$google_params,$cparams);
    return $google_params;
    
}

sub build_post_content {
    my ($req_info,$rule_env,$args,$scope,$parameters) = @_;
    my $logger = get_logger();
    my $content = undef;
    my $qadd = $args->[1];
    if (defined $qadd) {
        if (defined $qadd->{'quickadd'}) {
            $content = _quick_add($qadd->{'quickadd'});
        }
    }
    return $content;
}

sub _quick_add {
    my ($str) = @_;
    my $logger = get_logger();
    my $xml = <<_XML_;
<entry xmlns='http://www.w3.org/2005/Atom' xmlns:gCal='http://schemas.google.com/gCal/2005'>
  <content type="html">$str</content>
  <gCal:quickadd value="true"/>
</entry>
_XML_
    my $exml = encode("utf8",$xml);
    return $exml;
}

sub build_url {
    my ($parameters,$method) = @_;
    my $logger = get_logger();
    my $url="";
    if ($method eq 'POST') {
        $parameters->{'feed'} = 'event';
    }    
    $url = _feed_builder($parameters,$url);
    if ($method eq 'GET') {
        $url = _query_parts($parameters,$url);
    } else {
        $url .= '?alt=json';
    }
    return $url;
    
}

sub _query_parts {
    my ($parameters,$url_part) = @_;
    my $logger = get_logger();
    $logger->trace("Query params: ", sub {Dumper($parameters)});
    if (not $url_part =~ m/\?/) {
        $url_part .= '?';
    }
    my @parm_stack;
    foreach my $key ( keys %{ $parameters }){
        if (defined $parameters->{$key}) {
            my $val = $parameters->{$key};
            push (@parm_stack,"$key=$val");
        }
    };
    $url_part .= join ('&',@parm_stack);
    return $url_part;
}

sub prune_empty {
    my ($key,$val) = @_;
    if (defined $val) {
        return "$key=$val";
    } else {
        return undef;
    }
}

sub _feed_builder {
    my ($parameters,$url_part) = @_;
    $url_part = _base_part($parameters,$url_part);
    $url_part = _user_part($parameters,$url_part);
    my $feed = $parameters->{'feed'};
    $parameters->{'feed'} =undef;
    if ($feed eq 'allcalendars' || $feed eq 'owncalendars') {
        $url_part .= "/$feed";
        $url_part = _projection_part($parameters,$url_part);
    } elsif ($feed eq 'event') {
        $url_part = _visibility_part($parameters,$url_part);
        $url_part = _projection_part($parameters,$url_part); 
        $url_part = _event_id_part($parameters,$url_part);       
    } elsif ($feed eq 'comments') {
        $url_part = _visibility_part($parameters,$url_part);
        $url_part = _projection_part($parameters,$url_part); 
        $url_part = _event_id_part($parameters,$url_part);
        $url_part .= '/comments';
        $url_part = _subfeed_entry_id_part($parameters,$url_part);  
    } elsif ($feed eq 'settings') {    
        $url_part .= '/settings';
        $url_part = _setting_preference_part($parameters,$url_part);
    }
    return $url_part;    
}

sub _setting_preference_part {
    my ($parameters,$url_part) = @_;
    my $preference = $parameters->{'preference_name'};
    if (defined $preference) {
        #$parameters->{'visibility'} = undef;
        #$parameters->{'projection'} = undef;
        $parameters->{'max-results'} = undef;
        $url_part .= "/$preference";
        $parameters->{'preference_name'} = undef;
    }
    return $url_part;
}

sub _subfeed_entry_id_part {
    my ($parameters,$url_part) = @_;
    my $eventid = $parameters->{'sub_feed_id'};
    if (defined $eventid) {
        $url_part .= "/$eventid";
        $parameters->{'sub_feed_id'} = undef;
    }
    return $url_part;
    
}


sub _event_id_part {
    my ($parameters,$url_part) = @_;
    my $eventid = $parameters->{'eventid'};
    if (defined $eventid) {
        $parameters->{'max-results'} = undef;
        $url_part .= "/$eventid";
        $parameters->{'eventid'} = undef;
    }
    return $url_part;
    
}

sub _visibility_part {
    my ($parameters,$url_part) = @_;
    $url_part .= '/' . $parameters->{'visibility'};
    $parameters->{'visibility'} = undef;
    return $url_part;    
}

sub _projection_part {
    my ($parameters,$url_part) = @_;
    $url_part .= '/' . $parameters->{'projection'};
    $parameters->{'projection'} = undef;
    return $url_part;
}

sub _user_part {
    my ($parameters,$url_part) = @_;
    my $logger = get_logger();
    $logger->debug("_user_part: ", sub {Dumper($parameters)});
    my $userid = $parameters->{'userid'};
    $parameters->{'userid'} = undef;
    return $url_part . $userid; 
}

sub _base_part {
    my ($parameters,$url_part) = @_;
    if ( !defined $google_config ) {
        $google_config = Kynetx::Configure::get_config('GOOGLE')->{'google'};
    }
    $url_part .= $google_config->{'scope'}->{'calendar'}->{'surl'};
    return $url_part;
    
}



1;
