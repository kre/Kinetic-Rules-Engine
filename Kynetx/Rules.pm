package Kynetx::Rules;
# file: Kynetx/Rules.pm

use strict;
use warnings;


use Data::UUID;
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

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
process_rules
eval_rule
get_rule_set 
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



sub process_rules {
    my $r = shift;

    my $logger = get_logger();

    $r->subprocess_env(START_TIME => Time::HiRes::time);


    if($r->dir_config('run_mode') eq 'development') {
	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
#        $r->connection->remote_ip('128.122.108.71'); # New York (NYU)
	$r->connection->remote_ip('72.21.203.1'); # Seattle (Amazon)
#        $r->connection->remote_ip('128.187.16.242'); # Utah (BYU)
	$logger->debug("In development mode using IP address ", $r->connection->remote_ip());
    } 



    # get a session hash 
    my $session = process_session($r);

    # grab request params
    my $req = Apache2::Request->new($r);


    # build initial envv
    my $ug = new Data::UUID;
    my $path_info = $r->path_info;
    my $request_info = {
	host => $r->connection->get_remote_host,
	caller => $r->headers_in->{'Referer'} || $req->param('caller'),
	now => time,
	site => $path_info =~ m#/eval/([^/]+)/.*\.js#,
	hostname => $r->hostname(),
	ip => $r->connection->remote_ip() || '0.0.0.0',
	ua => $r->headers_in->{UserAgent} || '',
	pool => $r->pool,
	txn_id => $ug->create_str(),
	};
    

    my @param_names = $req->param;
    foreach my $n (@param_names) {
	$request_info->{$n} = $req->param($n);
    }
    $request_info->{'param_names'} = \@param_names;

#     $request_info->{'referer'} = $req->param('referer');
#     $request_info->{'title'} = $req->param('title');
#     $request_info->{'kvars'} = $req->param('kvars');


    Log::Log4perl::MDC->put('site', $request_info->{'site'});
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    $logger->info("Processing rules for site " . $request_info->{'site'});

    # side effects environment with precondition pattern values
    my ($rules, $rule_env, $global) = 
	get_rule_set($request_info->{'site'}, 
		     $request_info->{'caller'},
		     $r->dir_config('svn_conn'),
		     $request_info
	);



    if($logger->is_debug()) {
	foreach my $entry (keys %{ $request_info }) {
	    $logger->debug($entry . ": " . $request_info->{$entry}) 
		unless($entry eq 'param_names' || $entry eq 'selected_rules');
	}
    }

    # FIXME: the above loop ought to intelligently deal with arrays
    if($request_info->{'param_names'}) {
	$logger->debug("param_names: [" . join(", ", @{ $request_info->{'param_names'} }) . "]");
    }

    if($request_info->{'selected_rules'}) {
	$logger->debug("selected_rules: [" . join(", ", @{ $request_info->{'selected_rules'} }) . "]");
    }



    my $js = '';

    # handle globals

    if($global) {
	foreach my $g (@{ $global }) {

	    # emits
	    if($g->{'emit'}) {
		$js .= $g->{'emit'} . "\n";
	    }


	}
    }


    # this loops through the rules ONCE applying all that fire
    foreach my $rule ( @{ $rules } ) {
	$js .= eval_rule($r, $request_info, $rule_env, $session, $rule);
    }

    $logger->debug("Finished processing rules for " . $request_info->{'site'});
    print $js;

}

sub eval_rule {
    my($r, $request_info, $rule_env, $session, $rule) = @_;

    my $logger = get_logger();


    Log::Log4perl::MDC->put('rule', $rule->{'name'});
    $logger->info("selected ...");

    foreach my $var (keys %{ $rule_env } ) {
	$logger->debug("[Env] $var has value $rule_env->{$var}" 
		       ) if defined $rule_env->{$var};
    }

    foreach my $var (keys %{ $session } ) {
	$logger->debug("[Session] $var has value $session->{$var}");
    }



    # if the condition is undefined, it's true.  
    $rule->{'cond'} ||= mk_expr_node('bool','true');


    my $pred_value = 
	eval_predicates($request_info, $rule_env, $session, 
			$rule->{'cond'}, $rule->{'name'});


    # set up post block execution
    my($cons,$alt);
    if (ref $rule->{'post'} eq 'HASH') { # it's an array if no post block
	my $type = $rule->{'post'}->{'type'};
	if($type eq 'fired') {
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'alt'};
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
	$js .= build_js_load($rule, $request_info, $rule_env, $session); 
	
	$js .= eval_post_expr($cons, $session) if(defined $cons);

	# save things for logging
	push(@{ $rule_env->{'names'} }, $rule->{'name'});
	push(@{ $rule_env->{'results'} }, 'fired');
	push(@{ $rule_env->{'all_actions'} }, $rule_env->{'actions'});
	$rule_env->{'actions'} = ();
	push(@{ $rule_env->{'all_labels'} }, $rule_env->{'labels'});
	$rule_env->{'labels'} = ();
	push(@{ $rule_env->{'all_tags'} }, $rule_env->{'tags'});
	$rule_env->{'tags'} = ();



    } else {
	$logger->info("did not fire");

	$js .= eval_post_expr($alt, $session) if(defined $alt);

	# put this in the logging DB
	push(@{ $rule_env->{'names'} }, $rule->{'name'});
	push(@{ $rule_env->{'results'} }, 'notfired');
	push(@{ $rule_env->{'all_actions'} }, []);
	$rule_env->{'actions'} = ();
	push(@{ $rule_env->{'all_labels'} }, []);
	$rule_env->{'labels'} = ();
	push(@{ $rule_env->{'all_tags'} }, []);
	$rule_env->{'tags'} = ();


    }

    # put this in the logging DB
    log_rule_fire($r, 
		  $request_info, 
		  $rule_env,
		  $session
	);


    # return the JS load to the client
    $logger->info("finished");
    return $js; 

}



# this returns the right rules for the caller and site
# this is a point where things could be optimixed in the future
sub get_rule_set {
    my ($site, $caller, $svn_conn, $request_info) = @_;

    my $logger = get_logger();
    $logger->debug("Getting ruleset for $caller");

    my $ruleset = get_rules_from_repository($site, $svn_conn, $request_info);

    $ruleset = optimize_rules($ruleset);

    turn_on_logging() if($ruleset->{'meta'}->{'logging'} eq "on");
    
    $logger->debug("Found " . @{ $ruleset->{'rules'} } . " rules for site $site" );

    my @new_set;
    my %new_env;

    $request_info->{'rule_count'} = 0;
    $request_info->{'selected_rules'} = [];
    foreach my $rule ( @{ $ruleset->{'rules'} } ) {

# 	$logger->debug("Rule $rule->{'name'} is " . $rule->{'state'});

	if($rule->{'state'} eq 'active' || 
	   ($rule->{'state'} eq 'test' && 
	    $request_info->{'mode'} && 
	    $request_info->{'mode'} eq 'test' )) {  # optimize??


	    $request_info->{'rule_count'}++;

	
	    # test the pattern, captured values are stored in @captures
	    if(my @captures = $caller =~ get_precondition_test($rule)) {

		$logger->debug("[selected] $rule->{'name'} ");

		push @new_set, $rule;

		push @{ $request_info->{'selected_rules'} }, $rule->{'name'};


		# store the captured values from the precondition to the env
		my $cap = 0;
		foreach my $var ( @{ get_precondition_vars($rule)}) {

		    $var =~ s/^\s*(.+)\s*/$1/;

		    $logger->debug("[select var] $var -> $captures[$cap]");

		    $new_env{"$rule->{'name'}:$var"} = $captures[$cap++];
		    push(@{$new_env{$rule->{'name'}."_vars"}}, $var);


		}
                    
    
	    } else {
		$logger->debug("[not selected] $rule->{'name'} ");
		
	    }
    
	}
    
    }
    
    return (\@new_set, \%new_env, $ruleset->{'global'});

}

sub optimize_rules {
    my ($ruleset) = @_;

    foreach my $rule ( @{ $ruleset->{'rules'} } ) {

	# precompile pattern regexp
	$rule->{'pagetype'}->{'pattern'} = 
	    qr!$rule->{'pagetype'}->{'pattern'}!;

    }

    return $ruleset;
}


sub get_rules_from_repository{

    my ($site, $svn_conn, $request_info) = @_;

    my $logger = get_logger();

    my $memd = get_memd();

    my $ruleset = $memd->get("ruleset:$site");
    if ($ruleset) {
	$request_info->{'rule_version'} = $memd->get("ruleset_version:$site");
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
	my $svn_path = $svn_url.$site.$ext;
	eval {
	    $logger->debug("Getting info on ", $svn_path);
	    $ctx->info($svn_path, 
		       undef,
		       'HEAD',
		       $info,
		       0           # don't recurse
		);
	};
	if($@) {  # catch file doesn't exist...
#	    $logger->debug($svn_path, " returned error ", $@);
	    $d{$site.$ext} = -1;
	}
    }

    if ($d{$site.'.krl'} eq -1 && $d{$site.'.json'} eq -1) {
	$logger->debug("Ruleset $site not found; returning fake ruleset");
	return Kynetx::Parser::parse_ruleset("ruleset $site {}");
    }


    if($d{$site.'.krl'} > $d{$site.'.json'}) {
	$ext = '.krl';
    } else {
	$ext = '.json';
    }

    $request_info->{'rule_version'} = $d{$site.$ext};
    $logger->debug("Using the $ext version: ", $request_info->{'rule_version'});
    

    # open a variable as a filehandle (for weird SVN::Client stuff)
    my $krl;
    open(FH, '>', \$krl) or die "Can't open memory file: $!";
    $ctx->cat (\*FH,
	       $svn_url.$site.$ext, 
	       'HEAD');

    $logger->debug("Found rules for $site");

    # return the abstract syntax tree regardless of source
    if($ext eq '.krl') {
	$ruleset = Kynetx::Parser::parse_ruleset($krl);
    } else {
	$ruleset = jsonToAst($krl);
    }



    $logger->debug("Caching ruleset for $site");
    $memd->set("ruleset:$site", $ruleset);
    $memd->set("ruleset_version:$site", $request_info->{'rule_version'});
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
