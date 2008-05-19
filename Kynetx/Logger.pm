package Kynetx::Logger;
# file: Kynetx/Logger.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Session qw(:all);


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

    # FIXME: hardcoded database UID and password
    # Connect to the database.
    my $db_host = $r->dir_config('db_host');
    my $db_username = $r->dir_config('db_username');
    my $db_passwd = $r->dir_config('db_passwd');

    # should be using cached connection from Apache::DBI
    my $dbh = DBI->connect("DBI:mysql:database=logging;host=$db_host",
			   $db_username, $db_passwd,
			   {'RaiseError' => 1});

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


    my $req = Apache2::Request->new($r);
    $request_info{'referer'} = $req->param('referer');
    $request_info{'title'} = $req->param('title');
    
#     # we're going to process our own params
#     foreach my $arg (split('&',$r->args())) {
# 	my ($k,$v) = split('=',$arg);
# 	$request_info{$k} = $v;
# 	$request_info{$k} =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
#     }

    Log::Log4perl::MDC->put('site', $request_info{'site'});
    Log::Log4perl::MDC->put('rule', $request_info{'rule'}); 

    $logger->info("Processing callback for site " . $request_info{'site'});

    $logger->debug("Storing: ", $request_info{'site'}, ", ",
		               $request_info{'rule'}, ", ",
		               $request_info{'caller'}, ", ",
		               $session->{_session_id}, ", ",
		               $request_info{'sense'}, 
	);

    my $log_insert = "INSERT INTO callback_log VALUES (%d, '%s', '%s', '%s', '%s', '%s',now())";
    my $log_sql = sprintf($log_insert, 
	     undef,  # cause the id column to autoincrement
	     $request_info{'site'}, 
	     $request_info{'rule'}, 
	     $request_info{'caller'}, 
	     $session->{_session_id}, 
	     $request_info{'sense'}
	);

    $logger->debug("Using SQL: ", $log_sql);
    $dbh->do($log_sql);

    if($request_info{'url'}){
	$logger->debug("Redirecting to ", $request_info{'url'});
	print "window.location = '" . $request_info{'url'} . "'";
    }


}



