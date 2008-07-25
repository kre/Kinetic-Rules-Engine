package Kynetx::Session;
# file: Kynetx/Session.pm

use strict;
use warnings;


use Log::Log4perl qw(get_logger :levels);

use Kynetx::Memcached qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
process_session
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub process_session {
    my ($r) = @_;

    my $logger = get_logger();

    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/SESSION_ID=(\w*)/$1/ if(defined $cookie);

    if (defined $cookie) {
	$logger->debug("Using session id: ", $cookie );
    } else {
	$logger->debug("No session id found" );
    }

    my $session;

    eval {
	$session = tie_servers($session,$cookie);
    };

    # catch an error ($cookie not found is the most usual)
    if ($@) {
	undef $cookie; # creates a new session
	$logger->debug("Create cookie...");
	$session = tie_servers($session,$cookie);
    }
	
    # might be a new session, so lets give them their cookie back
    my $session_cookie = "SESSION_ID=$session->{_session_id};";
    $logger->debug("Sending cookie: ", $session_cookie);
    $r->headers_out->add('Set-Cookie' => $session_cookie);

    return $session;

}


sub tie_servers {

    my($session,$cookie) = @_;

    # presumes memcached has already been initialized
    my $mem_servers = Kynetx::Memcached::get_memcached_servers();

    my $logger = get_logger();
    $logger->debug("Using ", $mem_servers, " for session storage");


    tie %{$session}, 'Apache::Session::Memcached', $cookie, {
	Servers => $mem_servers,
	NoRehash => 1,
	Readonly => 0,
	Debug => 1,
	CompressThreshold => 10_000
    };

    return $session;

}

1;
