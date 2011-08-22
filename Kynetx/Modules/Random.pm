package Kynetx::Modules::Random;
# file: Kynetx/Modules/Random.pm
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
use Data::Dumper;

use XML::XML2JSON;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	get_predicates
	get_resources
	get_actions
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $default_actions = {
};

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;


sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}

my $funcs = {};



sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();
    $logger->trace("Function:", sub {Dumper($function)});
    my $resp = undef;
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info, $function, $args );
    	};
    	if ($@) {
    		$logger->warn("Random error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module Random");
    }

    return $resp;
}

sub rword {
	my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    return $DICTIONARY[rand(@DICTIONARY)];
}
$funcs->{'word'} = \&rword;

sub rquote {
	my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $qurl = 	"http://www.iheartquotes.com/api/v1/random";
	my $opts = {};
	if (ref $args->[0] eq "HASH") {
		foreach my $key (keys %{$args->[0]}) {
			$logger->debug("Key: ", $key);
			$opts->{$key} = $args->[0]->{$key};
		}
	}
	$opts->{'format'} = 'json';
	my $response = Kynetx::Modules::HTTP::mk_http_request('GET',undef,$qurl,$opts,undef);
	my $struct= Kynetx::Json::jsonToAst_w($response->{'_content'});
	return  $struct;
	
}
$funcs->{'quote'} = \&rquote;
$funcs->{'fortune'} = \&rquote;

sub rphoto {
	my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $purl = 	"http://picasaweb.google.com/data/feed/api/all";
	my $max = 1000;
	my $opts = {};
	$opts->{'alt'} = 'json';
	$opts->{'kind'} = 'photo';
	$opts->{'max-results'} = 1;
	if (ref $args->[0] eq "HASH") {
		foreach my $key (keys %{$args->[0]}) {
			$logger->debug("Key: ", $key);
			$opts->{$key} = $args->[0]->{$key};
		}
	}	
	$opts->{'q'} = 'kitten' unless (defined $opts->{'q'});
	$opts->{'start-index'} = int(rand($max)) +1  unless (defined $opts->{'start-index'});
	my $response = Kynetx::Modules::HTTP::mk_http_request('GET',undef,$purl,$opts,undef);
	my $struct = Kynetx::Json::jsonToAst_w($response->{'_content'});
	return $struct->{'feed'}->{'entry'}->[0]->{'media$group'};
}
$funcs->{'photo'} = \&rphoto;

1;
