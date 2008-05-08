
package Kynetx::Rules;
# file: Kynetx/Rules.pm

use strict;
use warnings;


use SVN::Client;
use Log::Log4perl qw(get_logger :levels);


use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Predicates qw(:all);
use Kynetx::Actions qw(:all);
use Kynetx::Log qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
process_rules
get_rule_set 
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



sub process_rules {
    my $r = shift;

    my $logger = get_logger();


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
	pool => $r->pool,
	);
    

    my $req = Apache2::Request->new($r);
    $request_info{'referer'} = $req->param('referer');
    $request_info{'title'} = $req->param('title');


    # we're going to process our own params
#     foreach my $arg (split('&',$r->args())) {
# 	my ($k,$v) = split('=',$arg,2);
# 	$request_info{$k} = $v;
# 	$request_info{$k} =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
#     }

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
	    $js .= build_js_load($rule, \%request_info, $rule_env, $session); 

	    $js .= eval_post_expr($cons, $session) if(defined $cons);

	    # put this in the logging DB
	    log_rule_fire($r, 
			  \%request_info, 
			  $rule_env,
			  $session, 
			  $rule->{'name'},
			  $rule->{'action'}->{'name'}
		);

	} else {
	    $logger->info("did not fire");

	    $js .= eval_post_expr($alt, $session) if(defined $alt);

	    # put this in the logging DB
	    log_rule_fire($r, 
			  \%request_info, 
			  $rule_env,
			  $session, 
			  $rule->{'name'},
			  'not_fired'
		);



	}

	# return the JS load to the client
	print $js; 
	$logger->info("finished");
    }

}


# this returns the right rules for the caller and site
# this is a point where things could be optimixed in the future
sub get_rule_set {
    my ($site, $caller, $svn_conn) = @_;

    my $logger = get_logger();
    $logger->debug("Getting rules for $caller");

    my $rules = optimize_rules(
	          get_rules_from_repository($site, $svn_conn),$site);


    my @new_set;
    my %new_env;

    foreach my $rule ( @{ $rules->{$site} } ) {

	if($rule->{'state'} eq 'active') {  # optimize??

	    # test the pattern, captured values are stored in @captures
	    if(my @captures = $caller =~ get_precondition_test($rule)) {

		push @new_set, $rule;

		# store the captured values from the precondition to the env
		my $cap = 0;
		foreach my $var ( @{ get_precondition_vars($rule)}) {

		    $logger->debug("[select var] $var -> $captures[$cap]");

		    $new_env{"$rule->{'name'}:$var"} = $captures[$cap++];

		}
                    
    
	    } else {
		$logger->debug("[not selected] $rule->{'name'} ");
		
	    }
    
	}
    
    }
    
    return (\@new_set, \%new_env);

}

sub optimize_rules {
    my ($rules, $site) = @_;

    foreach my $rule ( @{ $rules->{$site} } ) {

	# precompile pattern regexp
	$rule->{'pagetype'}->{'pattern'} = 
	    qr!$rule->{'pagetype'}->{'pattern'}!;

    }

    return $rules;
}


sub get_rules_from_repository{

    my ($site, $svn_conn) = @_;

    my $logger = get_logger();

    my $memd = get_memd();

    my $ruleset = $memd->get("ruleset:$site");
    if ($ruleset) {
	$logger->debug("Using cached ruleset for $site");
	return $ruleset;
    } 


    my ($ctx, $svn_url) = get_svn_conn($svn_conn);

    my %d;
    my $info = sub {
	my( $path, $info, $pool ) = @_;
	$d{$path} = $info->last_changed_rev();
    };

    my $ext;
    foreach $ext ('.krl','.json') {
	eval {
	    $ctx->info($svn_url.$site.$ext, 
		       undef,
		       'HEAD',
		       $info,
		       0           # don't recurse
		);
	};
	if($@) {  # catch file doesn't exist...
	    $d{$site.$ext} = -1;
	}
    }

    if ($d{$site.'.krl'} eq -1 && $d{$site.'.json'} eq -1) {
	$logger->debug("Didn't find any rules, returning fake ruleset");
	return parse_ruleset("ruleset $site {}");
    }


    if($d{$site.'.krl'} > $d{$site.'.json'}) {
	$ext = '.krl';
    } else {
	$ext = '.json';
    }

    $logger->debug("Using the $ext version: ", $d{$site.$ext});
    

    # open a variable as a filehandle (for weird SVN::Client stuff)
    my $krl;
    open(FH, '>', \$krl) or die "Can't open memory file: $!";
    $ctx->cat (\*FH,
	       $svn_url.$site.$ext, 
	       'HEAD');

    $logger->debug("Found rules for $site");

    # return the abstract syntax tree regardless of source
    if($ext eq '.krl') {
	$ruleset = parse_ruleset($krl);
    } else {
	$ruleset = jsonToAst($krl);
    }

    $logger->debug("Caching ruleset for $site");
    $memd->set("ruleset:$site", $ruleset);
    return $ruleset;    

}

sub get_svn_conn {
    my($svn_conn) = @_;
    my $logger = get_logger();

    my ($svn_url,$username,$passwd);
    if ($svn_conn) {
	($svn_url,$username,$passwd) = split(/\|/, $svn_conn);
    } else {
	$svn_url = 'svn://127.0.0.1/rules/client/';
	$username = 'web';
	$username = 'foobar';
    }

    
    $logger->debug("Connecting to rule repository at $svn_url");


    my $simple_prompt = sub {
	my $cred = shift;
	my $realm = shift;
	my $default_username = shift;
	my $may_save = shift;
	my $pool = shift;

	$cred->username($username);
	$cred->password($passwd);
    };

    # returns a list with the connection and the URL
    return (new SVN::Client(
		auth => [SVN::Client::get_simple_provider(),
			 SVN::Client::get_simple_prompt_provider($simple_prompt,2),
			 SVN::Client::get_username_provider()]
	    ), 
	    $svn_url)

    

}




1;
