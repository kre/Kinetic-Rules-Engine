package Kynetx::Logger;
# file: Kynetx/Logger.pm
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
use Data::UUID;

use Kynetx::Session qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Version qw(:all);


sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    Log::Log4perl::MDC->put('site', '[global]');
    Log::Log4perl::MDC->put('rule', '[callbacks]'); 

    $r->content_type('text/javascript');

    # set up memcached
    Kynetx::Memcached->init();

    if($r->path_info =~ m!/version/! ) {
    # store these for later logging
	$r->subprocess_env(METHOD => 'version');
	show_build_num($r);
    } else {
	process_action($r);
    }

    return Apache2::Const::OK; 
}


1;


sub process_action {
    my $r = shift;

    my $logger = get_logger();


    $r->subprocess_env(START_TIME => Time::HiRes::time);


    # get a session hash from the cookie or build a new one
    my $session = process_session($r);

    # build initial env
    my $ug = new Data::UUID;
    my $path_info = $r->uri;
    my %request_info = (
	host => $r->connection->get_remote_host,
	caller => $r->headers_in->{'Referer'},
	now => time,
	site => $path_info =~ m#/log|callback/([^/]+)#,
	hostname => $r->hostname(),
	ip => $r->connection->remote_ip(),
	txn_id => $ug->create_str(),
	);

    Log::Log4perl::MDC->put('site', $request_info{'site'});

    my $req = Apache2::Request->new($r);


    # store these for later logging
    $r->subprocess_env(METHOD => 'callback');
    $r->subprocess_env(RIDS => $request_info{'site'});
    $r->subprocess_env(SITE => $request_info{'site'});

    # make sure we use the one sent, not the one for this interaction
    $r->subprocess_env(TXN_ID => $req->param('txn_id'));
    $r->subprocess_env(CALLER => $request_info{'caller'});

    my $sid = $session->{'_session_id'};
    $r->subprocess_env(SID => $sid);

    $r->subprocess_env(IP => $request_info{'ip'});
    $r->subprocess_env(REFERER => $request_info{'referer'});
    $r->subprocess_env(TITLE => $request_info{'title'});
    $r->subprocess_env(URL => $req->param('url'));
    $r->subprocess_env(SENSE => $req->param('sense'));
    $r->subprocess_env(TYPE => $req->param('type'));
    $r->subprocess_env(ELEMENT => $req->param('element'));
    $r->subprocess_env(RULE_NAME => $req->param('rule'));

    if($req->param('type') eq 'click') {
	$r->subprocess_env(CB_INFO => $req->param('url'));
    }

    $logger->debug("Finish time: ", time, " Start time: ", $r->subprocess_env('START_TIME'));
   




#     $logger->debug("Storing: ", $request_info{'site'}, ", ",
# 		               $request_info{'txn_id'}, ", ",
# 		               $request_info{'rule'}, ", ",
# 		               $request_info{'caller'}, ", ",
# 		               $session->{_session_id}, ", ",
# 		               $request_info{'type'}, ", ",
# 		               $request_info{'element'}, ", ",
# 		               $request_info{'sense'}, 
# 	);



#     my $log_insert = "INSERT INTO callback_log VALUES (%d, '%s', '%s', '%s', '%s', '%s',now())";
#     my $log_sql = sprintf($log_insert, 
# 	     undef,  # cause the id column to autoincrement
# 	     $request_info{'site'}, 
# 	     $request_info{'rule'}, 
# 	     $request_info{'caller'}, 
# 	     $session->{_session_id}, 
# 	     $request_info{'sense'}
# 	);

#     $logger->debug("Using SQL: ", $log_sql);
#     $dbh->do($log_sql);

    if($req->param('url')){
	my $url = $req->param('url');
	$logger->debug("Redirecting to ", $url);
	print "window.location.replace('$url');";


    }

    $logger->info("Processing callback for site " . $request_info{'site'} . " and rule " . $req->param('rule'));

    $r->subprocess_env(TOTAL_SECS => Time::HiRes::time - 
	$r->subprocess_env('START_TIME'));

}



