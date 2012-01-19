package Kynetx::Predicates::Markets;
# file: Kynetx/Predicates/Markets.pm
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
