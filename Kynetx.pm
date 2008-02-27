package Kynetx;
# file: Kynetx.pm

use strict;
use warnings;


use XML::XPath;
use LWP::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);
use Cache::Memcached;

use Kynetx::Rules qw(:all);;
use Kynetx::Util qw(:all);;
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Predicates qw(:all);
use Kynetx::Actions qw(:all);




my $logger;
$logger = get_logger();

# Make this global so we can use memcache all over
our $memd;

if($logger->is_debug()) {

    use Data::Dumper;
}


my $s = Apache2::ServerUtil->server;

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');
    
    my @host_array = $r->dir_config->get('memcached_hosts');

    if($r->dir_config('memcached_hosts')) {
	Kynetx::Memcached->init(\@host_array);
    }

    # at some point we need a better dispatch function
    if($r->path_info =~ m!/flush/! ) {
	flush_ruleset_cache($r);
    } else {
	process_rules($r);
    }

    return Apache2::Const::OK; 
}

1;


sub process_rules {
    my $r = shift;
  

    if($r->dir_config('run_mode') eq 'development') {
	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
#        $r->connection->remote_ip('128.122.108.71'); # New York (NYU)
	$r->connection->remote_ip('72.21.203.1'); # Seattle (Amazon)
#        $r->connection->remote_ip('128.187.16.242'); # Utah (BYU)
    }


    # get a session hash 
    my $session = process_session($r);

    # build initial env
    my $path_info = $r->path_info;
    my %request_info = (
	host => $r->connection->get_remote_host,
	caller => $r->headers_in->{'Referer'},
	now => time,
	site => $path_info =~ m#/(\d+)/.*\.js#,
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
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    $logger->info("Processing rules for site " . $request_info{'site'});

    if($logger->is_debug()) {
	foreach my $entry (keys %request_info) {
	    $logger->debug($entry . ": " . $request_info{$entry});
	}
    }

    # side effects environment with precondition pattern values
    my ($rules, $rule_env) = get_rule_set($request_info{'site'}, 
					  $request_info{'caller'},
					  $r->dir_config('svn_conn'));

    # this loops through the rules ONCE applying all that fire
    foreach my $rule ( @{ $rules } ) {

	Log::Log4perl::MDC->put('rule', $rule->{'name'});
	$logger->info("selected ...");

	foreach my $var (keys %{ $rule_env } ) {
	    $logger->debug("[Env] $var has value $rule_env->{$var}");
	}


	my $pred_value = 
	    eval_predicates(\%request_info, $rule_env, $session, $rule);


	# set up post block execution
	my($cons,$alt);
	if (ref $rule->{'post'} eq 'HASH') { # it's an array if no post block
	    my $type = $rule->{'post'}->{'type'};
	    if($type eq 'fired') {
		$cons = $rule->{'post'}->{'cons'};
		$alt = $rule->{'post'}->{'alt'};
# 	    } elsif($type eq 'failure') { # reverse them
# 		$cons = $rule->{'post'}->{'alt'};
# 		$alt = $rule->{'post'}->{'cons'};
	    } elsif($type eq 'always') { # cons is executed on both paths
		$cons = $rule->{'post'}->{'cons'};
		$alt = $rule->{'post'}->{'cons'};
	    }


	}

	my $js = '';
	if ($pred_value) {

	    $logger->info("fired");

	    # this is the main event.  The browser has asked for a
	    # chunk of Javascrip and this is where we deliver... 
	    $js .= mk_action($rule, \%request_info, $rule_env, $session); 

	    $js .= eval_post_expr($cons, $session) if(defined $cons);

	} else {
	    $logger->info("did not fire");

	    $js .= eval_post_expr($alt, $session) if(defined $alt);


	}

	# return the JS load to the client
	print $js; 
	$logger->info("finished");
    }

}







sub flush_ruleset_cache {
    my ($r) = @_;

    # nothing to do if no memcache hosts
    return unless $r->dir_config('memcached_hosts');

    my ($site) = $r->path_info =~ m#/(\d+)#;

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...


    $logger->debug("[flush] flushing rules for $site");
    my $memd = get_memd();
    $memd->delete("ruleset:$site");

    $r->content_type('text/html');
    print "<h1>Rules flushed for site $site</h1>";

}



