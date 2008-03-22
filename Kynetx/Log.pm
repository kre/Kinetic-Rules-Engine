package Kynetx::Log;
# file: Kynetx/Log.pm

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
log_rule_fire
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub log_rule_fire {
    my ($r, $request_info, $session, $rule_name, $action) = @_;

    my $logger = get_logger();

    my $db_host = $r->dir_config('db_host');
    my $db_username = $r->dir_config('db_username');
    my $db_passwd = $r->dir_config('db_passwd');

    $logger->debug("Attaching to DB at $db_host with user $db_username and $db_passwd");

    # should be using cached connection from Apache::DBI
    my $dbh = DBI->connect("DBI:mysql:database=logging;host=$db_host",
			   $db_username, $db_passwd,
			   {'RaiseError' => 1});


    
    my $log_insert = 
	"INSERT INTO rule_log VALUES (%d, now(), %s, %s, %s, %s, %s, %s, %s, %s)";
    my $log_sql = sprintf($log_insert, 
			  undef, # undef cause the id column to autoincrement
			  $dbh->quote($request_info->{'site'}), 
			  $dbh->quote($rule_name),
			  $dbh->quote($request_info->{'caller'}), 
			  $dbh->quote($session->{_session_id}), 
			  $dbh->quote($request_info->{'ip'}),
			  $dbh->quote($request_info->{'referer'}),
			  $dbh->quote($request_info->{'title'}),
			  $dbh->quote($action)
	);

    $logger->debug("Using SQL: ", $log_sql);
    $dbh->do($log_sql);

    # Disconnect from the database.
    $dbh->disconnect();

}


1;
