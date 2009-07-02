package Kynetx::Configure;
# file: Kynetx/Configure.pm
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

use YAML::XS;

use Data::Dumper;
$Data::Dumper::Indent = 1;


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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant DEFAULT_CONFIG_FILE => '/web/etc/kns_config.yml';

our $config;

sub configure {
    my($filename) = @_;

    $config = read_config($filename || DEFAULT_CONFIG_FILE);

    # this is stuff for config that we don't put in the config file
    $config->{'JS_VERSION'} = '0.9';
    $config->{'DEFAULT_JS_ROOT'} = $config->{'KOBJ_ROOT'} . '/etc/js';
    $config->{'FRAG_HOST'} = 'frag.kobj.net';

    $config->{'DEFAULT_TEMPLATE_DIR'} = $config->{'KOBJ_ROOT'} . '/etc/tmpl';

 
    # note that Apache::Session::Memecached wants a space delimited string
    $config->{'SESSION_SERVERS'} = 
	join(" ", 
	     map {$_ . ":" . $config->{'sessions'}->{'session_port'} } 
	         @{ $config->{'sessions'}->{'session_hosts'} });


    # note that Cache::Memcached wants an array
    my @mservers = map {$_ . ":" . $config->{'memcache'}->{'mcd_port'} } 
	          @{ $config->{'memcache'}->{'mcd_hosts'} };	   
    $config->{'MEMCACHE_SERVERS'} = \@mservers;
	  


    return 1;
}



sub get_config {
    my ($name) = @_;
    return $config->{$name};
}

sub config_keys {
    my @keys = keys %{ $config };
    return  \@keys;
}


sub get_mcd_hosts {
    return $config->{'memcache'}->{'mcd_hosts'};
}

sub get_mcd_port {
    return $config->{'memcache'}->{'mcd_port'};
}


sub read_config {
    my ($filename) = @_;

    my $config = YAML::XS::LoadFile($filename) || 
	warn "Can't open configuration file $filename: $!";
    return $config;
}




1;


