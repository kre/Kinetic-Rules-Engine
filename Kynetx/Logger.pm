package Kynetx::Logger;
# file: Kynetx/Logger.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);


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

    # get a session hash from the cookie or build a new one
    my $session = process_session($r);

    # build initial env
    my $path_info = $r->uri;
    my %request_info = (
	host => $r->connection->get_remote_host,
	caller => $r->headers_in->{'Referer'},
	now => time,
	site => $path_info =~ m#/log/(\d+)#,
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
		               $session->{_session_id}, ", ",
		               $request_info{'sense'}, 
	);

    # store to db here

    if($request_info{'url'}){
	$logger->debug("Redirecting to ", $request_info{'url'});
	print "window.location = '" . $request_info{'url'} . "'";
    }


}




