package Kynetx::Logger;
# file: Kynetx/Logger.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

Log::Log4perl->init_and_watch("/web/lib/perl/log4perl.conf", 60);

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');

    process_action($r);

    return Apache2::Const::OK; 
}


1;


sub process_action {
    my $r = shift;

    my $logger = get_logger();
    $logger->info("Processing callback for site " . $r->path_info);
  
    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/SESSION_ID=(\w*)/$1/ if(defined $cookie);


    my %session;
    # need to get rid of hard coded values here.
    tie %session, 'Apache::Session::DB_File', $cookie, {
	FileName      => '/web/data/sessions.db',
	LockDirectory => '/var/lock/sessions',
    };
	
    #Might be a new session, so lets give them their cookie back
    my $session_cookie = "SESSION_ID=$session{_session_id};";
    $r->headers_out->add('Set-Cookie' => $session_cookie);

    # build initial env
    my $path_info = $r->path_info;
    my %request_info = (
	host => $r->connection->get_remote_host,
	caller => $r->headers_in->{'Referer'},
	now => time,
	site => $path_info =~ m#/(\d+)/.*#,
	hostname => $r->hostname(),
	ip => $r->connection->remote_ip(),
	);
    
    # we're going to process our own params
    foreach my $arg (split('&',$r->args())) {
	my ($k,$v) = split('=',$arg);
	$request_info{$k} = $v;
	$request_info{$k} =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    }

    Log::Log4perl::MDC->put('site', $request_info{'site'});
    Log::Log4perl::MDC->put('rule', $request_info{'rule'}); 

    $logger->info("Processing callback for site " . $request_info{'site'});

    $logger->debug("Storing: ", $request_info{'site'}, ", ",
		               $request_info{'rule'}, ", ",
		               $request_info{'caller'}, ", ",
		               $session{_session_id}, ", ",
		               $request_info{'sense'}, 
	);

    # store to db here

    if($request_info{'url'}){
	$logger->debug("Redirecting to ", $request_info{'url'});
	print "window.location = '" . $request_info{'url'} . "'";
    }


}




