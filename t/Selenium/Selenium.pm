package t::Selenium::Selenium;
# file: t/Selenium/Selenium.pm
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
