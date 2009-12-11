package Kynetx::Util;
# file: Kynetx/Util.pm
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
use Log::Log4perl::Level;

use Kynetx::Memcached qw(:all);
use URI::Escape ('uri_escape');



use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
reduce
cdr
before_now
after_now
mk_created_session_name
config_logging
turn_on_logging
turn_off_logging
mk_url
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;




# set up logging
sub config_logging {
    my ($r) = @_;
    # we can use the 'debug' config parameter to force detailed logging

    my $appender = Log::Log4perl::Appender->new(
	"Log::Dispatch::File",
	filename => "/web/logs/detail_log",
	mode     => "append",
        name     => "FileLogger"
	);

    my $logger = get_logger("Kynetx");

    $logger->add_appender($appender);
     
    # Layouts
    my $layout = 
	Log::Log4perl::Layout::PatternLayout->new(
	    "%d %p %F{1} %X{site} %X{rule} %m%n");
    $appender->layout($layout);

    my $mode = Kynetx::Configure::get_config('RUN_MODE');
    my $debug = Kynetx::Configure::get_config('DEBUG');
    if($mode eq 'development' || $debug eq 'on') {
	$logger->level($DEBUG);
    } elsif($mode eq 'production') {
	$logger->level($WARN);
    }

}


sub turn_on_logging {

    my $logger = get_logger('Kynetx');
    
    # match any newline not at the end of the string
    my $re = qr%\n(?!$)%;
    my $appender = Log::Log4perl::Appender->new(
	"Log::Dispatch::Screen",
	stderr => 0,
	name => "ConsoleLogger",
	callbacks => sub{my (%h) = @_;
			 $h{'message'} =~ s%$re%\n//%gs; 
			 return $h{'message'};
	}
	);
     

    $logger->add_appender($appender);

    # don't write detailed logs unless we're already in debug mode
    $logger->remove_appender('FileLogger') unless $logger->is_debug();
    $logger->level($DEBUG);
    
    # Layouts
    my $layout = 
	Log::Log4perl::Layout::PatternLayout->new(
	    "// %d %p %F{1} %X{site} %X{rule} %m%n"
	);
    $appender->layout($layout);

}

sub turn_off_logging {
    my $logger = get_logger('Kynetx');
    $logger->remove_appender('ConsoleLogger');
}

# takes a counter name and makes a uniform session var name from it
sub mk_created_session_name {
    my $name = shift;
    return $name.'_created';
}

# From HOP
# reduce(sub { $a + $b }, @VALUES)
sub reduce (&@) {
    my $code = shift;
    my $val = shift;
    for (@_) {
	local($a, $b) = ($val, $_);
	$val = $code->($val, $_);
    }
    return $val;
}


sub cdr { shift; @_ } 

sub before_now {
    my $desired = shift;

    my $now = DateTime->now;

    my $ans = DateTime->compare($now,$desired);

#    my $logger = get_logger();
#    $logger->debug("[before_now] is $now  after $desired: $ans" );

    # 1 if first greater than second
    return $ans == 1;

}


sub after_now {
    my $desired = shift;

    # ensure consistently get 0 or 1 for testing
    return before_now($desired) ? 0 : 1;

}

sub mk_url {
  my ($base_url, $url_options) = @_;

  $base_url .= join('&', map("$_=".uri_escape($url_options->{$_}), keys %{ $url_options }));


  return $base_url;
}

1;
