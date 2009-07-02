package Kynetx::Log;
# file: Kynetx/Log.pm
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
    my ($r, $request_info, $session) = @_;

    my $logger = get_logger();

    $logger->debug("[logging] Storing logging data for " . $request_info->{'rids'} );


    $r->subprocess_env(SITE => $request_info->{'rids'});

    $r->subprocess_env(RULE_NAMES => 
		       join(',', @{ $request_info->{'names'} } ) 
		       
	) if defined $request_info->{'names'};

    $r->subprocess_env(RESULTS => 
		       join(',', @{ $request_info->{'results'} } ) 
		       
	) if defined $request_info->{'results'};


    my @fired = grep(/^fired$/,@{ $request_info->{'results'}  });
    $r->subprocess_env(RSE => 1)
	 if @fired && int(@fired) > 0;

    

    $r->subprocess_env(CALLER => $request_info->{'caller'});

    my $sid = $session->{'_session_id'};
    $r->subprocess_env(SID => $sid);

    $r->subprocess_env(IP => $request_info->{'ip'});
    $r->subprocess_env(REFERER => $request_info->{'referer'});
    $r->subprocess_env(TITLE => $request_info->{'title'});

    $logger->debug("TXN_ID: ", $request_info->{'txn_id'});
    $r->subprocess_env(TXN_ID => $request_info->{'txn_id'});

    $r->subprocess_env(TOTAL_SECS => Time::HiRes::time - 
	$r->subprocess_env('START_TIME'));

    $r->subprocess_env(ACTIONS => 
			join(',', map(array_to_string($_),
				      @{ $request_info->{'all_actions'} }))
	) if defined $request_info->{'all_actions'};

    $r->subprocess_env(TAGS => 
			join(',', map(array_to_string($_),
				      @{ $request_info->{'all_tags'} }))
	) if defined $request_info->{'all_tags'};

    $r->subprocess_env(LABELS => 
		       join(',', map(array_to_string($_),
				     @{ $request_info->{'all_labels'} }))
	) if defined $request_info->{'all_labels'};


}
    

sub array_to_string {
    my ($arr) = @_;

    my $a;

    if(ref($arr) eq 'ARRAY' && scalar( @{ $arr } ) > 0) {
	$a = '[' . join(',', @{ $arr }) . ']';
    } else {
	$a = '[]'
    }

    return $a;
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
