package Kynetx::Session;
# file: Kynetx/Session.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);


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

    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/SESSION_ID=(\w*)/$1/ if(defined $cookie);

    my %session;
    eval {
	tie %session, 'Apache::Session::DB_File', $cookie, {
	    FileName      => '/web/data/sessions.db',
	    LockDirectory => '/web/lock/sessions',
	};
    };

    # catch an error ($cookie not found is the most usual)
    if ($@) {
	undef $cookie; # creates a new session
	tie %session, 'Apache::Session::DB_File', $cookie, {
	    FileName      => '/web/data/sessions.db',
	    LockDirectory => '/web/lock/sessions',
	};
	    
    }
	
    # might be a new session, so lets give them their cookie back
    my $session_cookie = "SESSION_ID=$session{_session_id};";
    $r->headers_out->add('Set-Cookie' => $session_cookie);

    return \%session

}

1;
