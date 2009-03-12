package Kynetx::Request;
# file: Kynetx/Request.pm

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
build_request_env
log_request_env
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub build_request_env {
    my ($r, $method, $rid) = @_;

    my $logger = get_logger();

    # grab request params
    my $req = Apache2::Request->new($r);

    # build initial envv
    my $ug = new Data::UUID;
    my $request_info = {
	host => $r->connection->get_remote_host || $req->param('host') || '',
	caller => $r->headers_in->{'Referer'} || $req->param('caller') || '',
	now => time,
	site => $rid,
	rid => $rid,
	method => $method,
	hostname => $r->hostname(),
	ip => $r->connection->remote_ip() || '0.0.0.0',
	ua => $r->headers_in->{'User-Agent'} || '',
	pool => $r->pool,
	txn_id => $ug->create_str(),
	};

    $request_info->{'page'} = $request_info->{'caller'};

    my @param_names = $req->param;
    foreach my $n (@param_names) {
	$request_info->{$n} = $req->param($n);
    }
    $request_info->{'param_names'} = \@param_names;

#     $request_info->{'referer'} = $req->param('referer');
#     $request_info->{'title'} = $req->param('title');
#     $request_info->{'kvars'} = $req->param('kvars');

    $logger->debug("Returning request information");

    return $request_info;
}


sub log_request_env {
    my ($logger, $request_info) = @_;
    if($logger->is_debug()) {
	foreach my $entry (keys %{ $request_info }) {
	    $logger->debug($entry . ": " . $request_info->{$entry}) 
		unless($entry eq 'param_names' || $entry eq 'selected_rules');
	}
# 	foreach my $h (keys %{ $r->headers_in }) {
# 	    $logger->debug($h . ": " . $r->headers_in->{$h});
# 	}
    }

    # FIXME: the above loop ought to intelligently deal with arrays
    if($request_info->{'param_names'}) {
	$logger->debug("param_names: [" . join(", ", @{ $request_info->{'param_names'} }) . "]");
    }

    if($request_info->{'selected_rules'}) {
	$logger->debug("selected_rules: [" . join(", ", @{ $request_info->{'selected_rules'} }) . "]");
    }

}


1;
