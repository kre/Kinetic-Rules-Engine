package Kynetx::Version;
# file: Kynetx/Version.pm
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

use JSON::XS;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_build_num
show_build_num
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub get_build_num {
    my ($kobj_root) = @_;
    my $build_num = `cd $kobj_root;/usr/bin/svnversion -n`;
    return $build_num || 'failed';
}

sub show_build_num {
    my ($r) = @_;

    my $kobj_root = Kynetx::Configure::get_config('KOBJ_ROOT');

    my $build_num = get_build_num($kobj_root);

    my $logger = get_logger();

    my ($site) = $r->path_info =~ m#/version/(.+)#;

    my $req = Apache2::Request->new($r);
    my $flavor = $req->param('flavor') || 'html';

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[version]');  # no rule for now...


    if($flavor eq 'json') {
	my $json = new JSON::XS;

	$r->content_type('text/plain');
	print $json->encode({'build_num' => $build_num}) ;
    } else {
	$r->content_type('text/html');
	my $msg = "KNS build number $build_num";
	print "<title>KNS Version</title><h1>$msg</h1>";
    }

}


1;
