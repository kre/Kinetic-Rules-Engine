package Kynetx::Log;
# file: Kynetx/Log.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use DateTime;
use Time::HiRes qw(time);

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
    my ($r, $request_info, $rule_env, $session, $rule_name, $action) = @_;

    my $logger = get_logger();

    $logger->debug("TXN_ID: ", $rule_env->{'txn_id'});

    $r->subprocess_env(SITE => $request_info->{'site'});
    $r->subprocess_env(RULE_NAME => $rule_name);
    $r->subprocess_env(CALLER => $request_info->{'caller'});
    $r->subprocess_env(SESSION_ID => $session->{_session_id});
    $r->subprocess_env(IP => $request_info->{'ip'});
    $r->subprocess_env(REFERER => $request_info->{'referer'});
    $r->subprocess_env(TITLE => $request_info->{'title'});
    $r->subprocess_env(TXN_ID => $request_info->{'txn_id'});
    $r->subprocess_env(UNIQ_ID => $rule_env->{'uniq_id'});

    $logger->debug("Finish time: ", time, " Start time: ", $r->subprocess_env('START_TIME'));
    $r->subprocess_env(TOTAL_SECS => Time::HiRes::time - 
	$r->subprocess_env('START_TIME'));

    $r->subprocess_env(ACTIONS => '['.
		       (($action eq 'not_fired') ?
			'not_fired' : 
			join(',', @{ $rule_env->{'actions'} })
		       ) . ']'
	);


}
    


#    $logger->debug("Attaching to DB at $db_host with user $db_username and $db_passwd");

#     # should be using cached connection from Apache::DBI
#     my $dbh = DBI->connect("DBI:mysql:database=logging;host=$db_host",
# 			   $db_username, $db_passwd,
# 			   {'RaiseError' => 1});


    
#     my $log_insert = 
# 	"INSERT INTO rule_log VALUES (%d, now(), %s, %s, %s, %s, %s, %s, %s, %s)";
#     my $log_sql = sprintf($log_insert, 
# 			  undef, # undef cause the id column to autoincrement
# 			  $dbh->quote($request_info->{'site'}), 
# 			  $dbh->quote($rule_name),
# 			  $dbh->quote($request_info->{'caller'}), 
# 			  $dbh->quote($session->{_session_id}), 
# 			  $dbh->quote($request_info->{'ip'}),
# 			  $dbh->quote($request_info->{'referer'}),
# 			  $dbh->quote($request_info->{'title'}),
# 			  $dbh->quote($action)
# 	);

#     $logger->debug("Using SQL: ($request_info->{'title'}) ", $log_sql);
#     $dbh->do($log_sql);

#     # Disconnect from the database.
#     $dbh->disconnect();





1;
