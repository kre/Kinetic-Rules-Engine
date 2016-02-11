package Kynetx::Configure;
# file: Kynetx/Configure.pm
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

use YAML::XS;
 
use Data::Dumper;
$Data::Dumper::Indent = 1;
use Log::Log4perl qw(get_logger :levels :easy);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
@mcd_hosts
get_mcd_hosts
get_mcd_port
get_config
config_keys
set_run_mode
set_debug
get_oauth_param
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant DEFAULT_CONFIG_FILE => '/web/etc/kns_config.yml';
use constant AMAZON =>  '/web/etc/Amazon';
use constant ACONFIG => 'locale.yml';
use constant GOOGLE => '/web/etc/Google';
use constant GCONFIG => 'gconfig.yml';
use constant RESPONSE_GROUP => 'response_group.yml';
use constant SEARCH_INDEX_FILE => 'searchindex.yml';
use constant FACEBOOK => '/web/etc/Facebook/facebook.yml';
use constant MODULES => '/web/etc/module_config.yml';
use constant SELENIUM => 'runtime_test/config/perl_selenium.yml';
use constant OAUTH_CONFIG_FILE => '/web/etc/oauth.yml';

our $config;

sub configure {
    my($filename) = @_;



    $config = read_config($filename || DEFAULT_CONFIG_FILE);

    # begin defaults
    $config->{'JS_VERSION'} ||= '0.9';
    $config->{'FRAG_HOST'} ||= 'frag.kobj.net';
    $config->{'MAX_SERVERS'} ||= '10';
    $config->{'MAX_REQUESTS_PER_CHILD'} ||= '50';

    # end defaults


    $config->{'DEFAULT_TEMPLATE_DIR'} = $config->{'KOBJ_ROOT'} . '/etc/tmpl';

    $config->{'DEFAULT_JS_ROOT'} = $config->{'KOBJ_ROOT'} . '/etc/js';

    # note that Apache::Session::Memecached wants a space delimited string
    $config->{'SESSION_SERVERS'} =
	join(" ",
	     map {$_ . ":" . $config->{'sessions'}->{'session_port'} }
	         @{ $config->{'sessions'}->{'session_hosts'} });


    # note that Cache::Memcached wants an array
    my @mservers = map {$_ . ":" . $config->{'memcache'}->{'mcd_port'} }
	          @{ $config->{'memcache'}->{'mcd_hosts'} };
    $config->{'MEMCACHE_SERVERS'} = \@mservers;

    set_run_mode();

    $config->{'OAUTH_CALLBACK_HOST'} = $config->{'EVAL_HOST'}
      unless $config->{'OAUTH_CALLBACK_HOST'};

    $config->{'OAUTH_CALLBACK_PORT'} = '80'
      unless $config->{'OAUTH_CALLBACK_PORT'};

    # Amazon
    $config->{'AMAZON'}->{'LOCALE'} = read_config(AMAZON.'/'.ACONFIG);
    $config->{'AMAZON'}->{'RESPONSE_GROUP'} = read_config(AMAZON . '/' . RESPONSE_GROUP);
    $config->{'AMAZON'}->{'SEARCH_INDEX'} = read_config(AMAZON . '/' . SEARCH_INDEX_FILE);

    # Google
    $config->{'GOOGLE'} = read_config(GOOGLE.'/'.GCONFIG);

    # Facebook
    $config->{'FACEBOOK'} = read_config(FACEBOOK);

    # General Module Catchall
    $config->{'MODULES'} = read_config(MODULES);
    
    # Selenium tests
    $config->{'SELENIUM'} = read_config($config->{'KOBJ_ROOT'} .'/' . SELENIUM);

    # OAuth URLS
    $config->{'OAUTH'} = read_config(OAUTH_CONFIG_FILE);
    
    # Values for metrics
    my @host = split(/\./,`hostname`);
    $config->{'METRICS'}->{'HOSTNAME'} = $host[0];
    $config->{'METRICS'}->{'PROC'} = $$;

    # HOST values
    $config->{'SCHEME'} ||= "https";
    $config->{'BASE_URL'} = $config->{'SCHEME'} . "://" . $config->{'EVAL_HOST'};
    $config->{'BASE_URL'} .= ":" . $config->{'KNS_PORT'} if(defined $config->{'KNS_PORT'});

    config_logging();
    return 1;
}

sub config_logging {
  my $conf_file = Kynetx::Configure::get_config('LOG_CONF') || '/web/etc/log.conf';
  if (Log::Log4perl->initialized()) {
    my $logger = Log::Log4perl::get_logger();
    $logger->debug("Logging ",Log::Log4perl::Level::to_level($logger->level()));
  } else {
    my $hostname = Sys::Hostname::hostname();
    Log::Log4perl->init_once($conf_file);
    Log::Log4perl::MDC->put( 'hostname', $hostname );
    my $appenders = Log::Log4perl->appenders();
    my $logger = Log::Log4perl::get_logger('');
    my $threshold = get_log_threshold();
    #$logger->level(Log::Log4perl::Level::to_priority($threshold));
  }

}

sub get_log_threshold {
  my $mode = Kynetx::Configure::get_config('RUN_MODE');
  my $debug = Kynetx::Configure::get_config('DEBUG');
  #return "DEBUG";
  if ($debug eq 'on') {
    return "DEBUG"
  } elsif ($debug eq 'off') {
    return "WARN"
  } elsif ($mode eq 'development') {
    return "DEBUG"
  } else {
    return "WARN"
  }
  
}


sub get_config {
    my ($name,$ns) = @_;
    if (defined $ns) {
        return $config->{$ns}->{$name};
    } else {
        return $config->{$name};
    }
}

sub get_version {
  return $VERSION;
}

sub set_run_mode {
    my ($mode) = @_;

    $mode = $mode || $config->{'RUN_MODE'} || 'production';
    $config->{'RUN_MODE'} = $mode;

    for my $k (qw/INIT_HOST CB_HOST EVAL_HOST KRL_HOST KNS_PORT COOKIE_DOMAIN OAUTH_CALLBACK_HOST OAUTH_CALLBACK_PORT LOGIN/) {
      $config->{$k} = $config->{$mode}->{$k};
    }

    return $mode;
}

sub set_debug {
    my ($debug) = @_;
    $config->{'DEBUG'} = $debug || $config->{'DEBUG'} || '';
    return $config->{'DEBUG'};
}

sub set_js_root {
    my ($js_root) = @_;
    $config->{'DEFAULT_JS_ROOT'} = $js_root || $config->{'DEFAULT_JS_ROOT'} || '';
}

sub config_keys {
    my @keys = keys %{ $config };
    return  \@keys;
}

sub get_properties {
    my %copy = %$config;
    return \%copy;
}


sub get_mcd_hosts {
    return $config->{'memcache'}->{'mcd_hosts'};
}

sub get_mcd_port {
    return $config->{'memcache'}->{'mcd_port'};
}

sub get_oauth_param {
    my ($namespace,$key) = @_;
    return $config->{'oauth'}->{$key}->{$namespace};
}


sub read_config {
    my ($filename) = @_;
    my $config;
    if ( -e $filename ) {
      $config = YAML::XS::LoadFile($filename) ||
	warn "Can't open configuration file $filename: $!";
    }
    return $config;
}

sub to_string {
    return Dumper($config);
}

1;


