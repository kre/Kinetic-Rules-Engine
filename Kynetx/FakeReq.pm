package Kynetx::FakeReq;
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

#
# This package simulates a mod_perl request object for testing
#
my $token = undef;
my $cookie = "7e9ea0ff190e0f883aaae0c3e64166c0";

#constructor
sub new {
    my ($class) = @_;
    my $self = {};
    $self->{'add'} = sub {return 1};
    bless $self, $class;
    return $self;
}

# fake methods for requests
sub subprocess_env {
    return 0;
}

sub content_type {
    return 0;
}

sub headers_in {
	if (defined $token) {		
		return {
			'Cookie' => "SESSION_ID=$cookie",
			'Kobj-Session' => $token
    	};
	} elsif (defined $cookie) {
    	return {
			'Cookie' => "SESSION_ID=$cookie",
		
		}
    }else {
    	return {};
    };
}

sub headers_out {
    my ($self) = @_;

    return $self;
}

sub add {
    return 1;
}

sub _set_session {
	my $self = shift;
	my ($newsession) = @_;
	$cookie = $newsession;
}

sub _delete_session {
	$cookie = undef;
}

sub _set_ubx_token {
	my $self = shift;
	my ($newtoken) = @_;
	$token = $newtoken;
}

1;
