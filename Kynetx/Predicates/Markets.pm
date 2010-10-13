package Kynetx::Predicates::Markets;
# file: Kynetx/Predicates/Markets.pm
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
use Encode;

use Kynetx::Memcached qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
get_stocks
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


# constants used in this module
use constant SERVICE_URL =>
      'http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=';

use constant SERVICE_EXPIRES => 60*20; # 20 minutes


my %predicates = (

    # market predicates

    'djia_up_more_than' => sub {
	my ($req_info, $rule_env, $args) = @_;
    my $logger = get_logger();
	my $threshold = $args->[0];

	my $dji = get_stocks($req_info, 'INDU', 'change');
    my $delta = int($dji);
    $logger->debug("Up: $dji|",$delta);
	# force the string to a num
	# 10 is an arbitrary threshold...
	return int($delta) > $threshold;
    },

    'djia_down_more_than' => sub {
	my ($req_info, $rule_env, $args) = @_;
    my $logger = get_logger();

	my $threshold = $args->[0];

	my $dji = get_stocks($req_info, 'INDU', 'change');
    my $delta = int($dji);
    $logger->debug("Down: $dji|",$delta);
	# force the string to a num
	# 10 is an arbitrary threshold...
	return int($delta) < (0 - $threshold);
    },


    );


sub get_predicates {
    return \%predicates;
}

# condition subfunctions
# first argument is a record of data about the request

sub get_stocks {
    my ($req_info, $symbol, $field) = @_;

    my @field_names = qw(
         symbol
         last
         date
         time
         change
         open
         high
         low
         volume
         previous_close
         name
         );

    if(not defined $req_info->{'stocks'}->{$symbol}->{$field}) {

	my $url = SERVICE_URL . $symbol;

	my $content = get_remote_data($url, SERVICE_EXPIRES);

	$content =~ s#.*<string.*>(.*)</string>.*#$1#ms;
	$content =~ s#&lt;#<#g;
	$content =~ s#&gt;#>#g;

	my $logger = get_logger();
	$logger->debug("Got quote for $symbol");
	$logger->debug("Quote for symbol ($symbol): " .
		       $content . " using " .$url
	    );



	my $rss = new XML::XPath->new(xml => $content);

	my $quote =
	    $rss ->find('/StockQuotes/Stock')->get_node(1);;

	foreach my $field (@field_names) {
	    my @parts = split(/_/,$field);
	    my $name = join('', map {ucfirst($_)} @parts);
	    my $v = $quote->findvalue($name)->value();

	    my $logger = get_logger();
	    $logger->debug(
		"Value for: " . ucfirst($field) . ' = ' . $v
		);

	    $req_info->{'stocks'}->{$symbol}->{$field} = $v;
	}




    }

    return $req_info->{'stocks'}->{$symbol}->{$field};

}



1;
