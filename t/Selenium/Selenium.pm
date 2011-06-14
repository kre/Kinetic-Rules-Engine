package t::Selenium::Selenium;
# file: t/Selenium/Selenium.pm
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

use Log::Log4perl qw(get_logger :levels);
use Test::WWW::Selenium;
use Data::Dumper;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Kynetx::Configure qw/:all/;
use constant CMODULE => 'SELENIUM';


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	bookmarklet_js
	destroy_selenium_clients
	init_selenium_clients
	make_selenium_config
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;


sub init_selenium_clients {
	my ($init_url) = @_;
	my $logger = get_logger();
	$init_url = 'http://www.kynetx.com' unless (defined $init_url);
	my $client_config = Kynetx::Configure::get_config("selenium_clients",CMODULE);
	my $clients = {};
	foreach my $client (keys %$client_config) {
		$logger->debug("Client: $client");
		my $host = $client_config->{$client}->{'host'};
		my $port = $client_config->{$client}->{'port'};
		my $browser = $client_config->{$client}->{'browser'};
		my $sel = Test::WWW::Selenium->new( host => $host, 
	                                    port => $port, 
	                                    browser => $browser,
	                                    browser_url =>  $init_url);
		$logger->debug(" host: $host");
		$sel->open();
		$sel->set_speed("1000");	
		$clients->{$client} = $sel;
	}
	return $clients;
	
}

sub destroy_selenium_clients {
	my ($clist) = @_;
	foreach my $browser_platform (keys %$clist) {
		my $c = $clist->{$browser_platform};
		$c->stop();
	}
}

sub make_selenium_config {
	my ($runmode) = @_;
	my $logger = get_logger();
	$runmode = Kynetx::Configure::get_config('RUN_MODE') unless (defined $runmode);
	my $init_host = Kynetx::Configure::get_config('INIT_HOST', $runmode);
	my $eval_host = Kynetx::Configure::get_config('EVAL_HOST', $runmode);
	my $krl_host  = Kynetx::Configure::get_config('KRL_HOST', $runmode);
	my $krl_port  = Kynetx::Configure::get_config('KRL_PORT', $runmode) || '80';
	my $cookie_domain = Kynetx::Configure::get_config('COOKIE_DOMAIN', $runmode);
	my $runtime = "http://$init_host/js/shared/kobj-static.js";
	$logger->info("INIT_HOST: $init_host");
	$logger->info("EVAL_HOST: $eval_host");
	$logger->info("KRL_HOST: $krl_host");
	$logger->info("KRL_PORT: $krl_port");
	$logger->info("COOKIE_DOMAIN: $cookie_domain");
	return {
		'init' => $init_host,
		'eval' => $eval_host,
		'krlh' => $krl_host,
		'krlp' => $krl_port,
		'runt' => $runtime
	};
}

sub bookmarklet_js {
	my ($config,$ridstring) = @_;
	my $ehost = $config->{'eval'};
	my $cbhost = $ehost;
	my $ihost = $config->{'init'};
	my $runtime = $config->{'runt'};	
	my $js = <<_JS_;
var d = window.document;var r = d.createElement('script'); r.text = 'KOBJ_config={"rids":["$ridstring"],init:{"eval_host":"$ehost","init_host":"$ihost"}} '; var body = d.getElementsByTagName('body')[0];body.appendChild(r);var q=d.createElement('script');q.src='$runtime';body.appendChild(q);
_JS_
	return $js;
}



1;
