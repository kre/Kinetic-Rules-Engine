package Apache::Kynetx;
# file: Apache/Kynetx.pm

use strict;
use warnings;


use XML::XPath;
use LWP::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);

use Kynetx::Rules qw(:all);;
use Kynetx::Util qw(:all);;
use Kynetx::JavaScript qw(:all);


Log::Log4perl->init_and_watch("/web/lib/perl/log4perl.conf", 60);

my $s = Apache2::ServerUtil->server;
my $debug = 0;
my $logger;

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');

    $debug = $r->dir_config('debug');

    # eventually we'll want to do this separately
    if((my $site) = ($r->path_info =~ m%/(\d+)/js/kobj.js%)) {

	print_kobj('http://','127.0.0.1',$site);

    } else {


	process_rules($r);
    }

    return Apache2::Const::OK; 
}


1;


sub process_rules {
    my $r = shift;
  
  
    # WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
#    $r->connection->remote_ip('128.122.108.71'); # New York (NYU)
    $r->connection->remote_ip('72.21.203.1'); # Seattle (Amazon)
#    $r->connection->remote_ip('128.187.16.242'); # Utah (BYU)

    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/SESSION_ID=(\w*)/$1/ if(defined $cookie);


    my %session;
    tie %session, 'Apache::Session::DB_File', $cookie, {
	FileName      => '/web/data/sessions.db',
	LockDirectory => '/var/lock/sessions',
    };
	
    #Might be a new session, so lets give them their cookie back

    my $session_cookie = "SESSION_ID=$session{_session_id};";
    $r->headers_out->add('Set-Cookie' => $session_cookie);


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

    $logger = get_logger();
    $logger->info("Processing rules for site " . $request_info{'site'});

    if($logger->is_debug()) {
	foreach my $entry (keys %request_info) {
	    $logger->debug($entry . ": " . $request_info{$entry});
	}
    }

    # side effects environment with precondition pattern values
    my ($rules, $rule_env) = get_rule_set($request_info{'site'}, $request_info{'caller'});

    # this loops through the rules ONCE applying all that fire
    foreach my $rule ( @{ $rules } ) {

	Log::Log4perl::MDC->put('rule', $rule->{'name'});
	$logger->info("selected ...");

	foreach my $var (keys %{ $rule_env } ) {
	    $logger->debug("[Env] $var has value $rule_env->{$var}");
	}


	my $pred_value = 
	    eval_predicates(\%request_info, $rule_env, \%session, $rule);


	# set up post block execution
	my($cons,$alt);
	if (ref $rule->{'post'} eq 'HASH') { # it's an array if no post block
	    my $type = $rule->{'post'}->{'type'};
	    if($type eq 'success') {
		$cons = $rule->{'post'}->{'cons'};
		$alt = $rule->{'post'}->{'alt'};
	    } elsif($type eq 'failure') { # reverse them
		$cons = $rule->{'post'}->{'alt'};
		$alt = $rule->{'post'}->{'cons'};
	    } elsif($type eq 'always') { # cons is executed on both paths
		$cons = $rule->{'post'}->{'cons'};
		$alt = $rule->{'post'}->{'cons'};
	    }


	}

	if ($pred_value) {

	    $logger->info("Rule fired");

	    # this is the main event.  The browser has asked for a
	    # chunk of Javascrip and this is where we deliver... 
	    print mk_action($rule, \%request_info, $rule_env, \%session); 

	    eval_post_expr($cons, \%session) if(defined $cons);
	    
	} else {
	    $logger->info("Rule did not fire");

	    eval_post_expr($alt, \%session) if(defined $alt);


	}
    }

}






sub mk_action {
    my ($rule, $req_info, $rule_env, $session) = @_;
#    my ($action) = @_;

    my $action = $rule->{'action'};
    my $action_name = $rule->{'action'}->{'name'};


    # create comma separated list of arguments 
    my $arg_str = 
       join(',', 
	     gen_js_rands($rule->{'action'}->{'args'})) || '';


    # do we need to pass this in anymore?
    my $uniq = int(rand 999999999);

    $arg_str = '\'' . $uniq . '\', ' . $arg_str;

    my $id_str = 'kobj_'.$uniq; 

    $logger->debug("[action] ", $action_name, 
		                 ' executing with args (',$arg_str,')');

    my $js = "";

    # set JS vars from rule env
    foreach my $var ( @{ get_precondition_vars($rule) } ) {
	my $val = $rule_env->{"$rule->{'name'}:$var"};
	$logger->debug("[JS var] ", $var, "->", $val);
	$js .= "var $var = \'" . $val . "\';\n";

    }


    $js .= gen_js_pre($req_info, $rule_env, $session, $rule->{'pre'});


    # apply the action function
    $js .= "(". $actions{$action_name} . "(" . $arg_str . "));\n";


    # set defaults
    my %mods = (
	delay => 0,
	effect => 'appear',
	scrollable => 0,
	draggable => 0,
	);

    # override defaults if set
    foreach my $m ( @{ $rule->{'action'}{'modifiers'} } ) {
	$mods{$m->{'name'}} = gen_js_expr($m->{'value'});
    }



    if($action_name eq "float") {
	
	$js .= "new Effect.toggle('" . $id_str . "', ". $mods{'effect'} . " );"  ;

	if($mods{'draggable'} eq 'true') {
	    $js .= "new Draggable('". $id_str . "', '{ zindex: 99999 }');";
	}

	if($mods{'scrollable'} eq 'true') {
	    $js .= "new FixedElement('". $id_str . "');";
	}

    } elsif($action_name eq "popup") {
	if ($mods{'effect'} eq 'onpageexit') {
	    my $funcname = "leave_" . $id_str;
	    $js = "function $funcname () { " . $js . "};\n";
	    $js .= "document.body.setAttribute('onUnload', '$funcname()');"
	}
    }

    

    if($mods{'delay'}) {
	# these ought to be pre-compiled on the rules
	$js =~ y/\n\r//d; # remove newlines
	$js =~ y/ //s;
	$js =~ s/'/\\'/g; # escape single quotes
	$js = "setTimeout(\'" . $js . "\', " . ($mods{'delay'} * 1000) . ")";
    }


    return $js . "\n\n";
}


sub eval_predicates {
    my($request_info, $rule_env, $session, $rule) = @_;

    my $conds = $rule->{'cond'};
    my $pred_value = 1;
    foreach my $cond ( @$conds ) {
	my $v;
	if (my $pred = $cond->{'predicate'}) {
	    my $predf = $Kynetx::Rules::predicates{$pred};

	    my @args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});


	    $v = &$predf($request_info, 
			 $rule_env, 
			 \@args
		);

	    $logger->debug('[predicate] ',
			   "$pred executing with args (" , 
			   join(', ', @args ), 
			   ')',
		           ' -> ',
		           $v);

	} elsif (my $name = $cond->{'name'}) {
	    # check count

	    my $count = $session->{$name} || 0;

	    $logger->debug('[counter] ', "$name -> $count");


	    if($cond->{'ineq'} eq '>') {
		$v =  $count > $cond->{'value'};
	    } elsif($cond->{'ineq'} eq '<') {
		$v = $count < $cond->{'value'};
	    } 

	    # check date, if needed
	    if($v &&
	       exists $cond->{'within'} &&
	       exists $session->{add_created($name)}) {

		my $desired = 
		    DateTime->from_epoch( epoch => 
					  $session->{add_created($name)});
		$desired->add( $cond->{'timeframe'} => $cond->{'within'} );

		$v = $v && before_now($desired);
	    }


	}

	$pred_value = $pred_value && $v;
    }
    return $pred_value;
}

sub eval_post_expr {
    my($expr, $session) = @_;

    $logger->debug("[post] ", $expr->{'type'});
    case: for ($expr->{'type'}) {
	/clear/ && do { 
	    if(exists $expr->{'counter'}) {
		delete $session->{$expr->{'name'}};
		delete $session->{add_created($expr->{'name'})}
	    }
	    return;
	};
	/iterator/ && do {
	    if(exists $expr->{'counter'}) {
		if(exists $session->{$expr->{'name'}}) {
		    $session->{$expr->{'name'}} += $expr->{'value'};
		} else {
		    $session->{$expr->{'name'}} = $expr->{'from'};
		    $session->{add_created($expr->{'name'})} = 
			# use DateTime for consistency 
			DateTime->now->epoch;
		}
	    }
	    return;
	};
    }

}

sub add_created {
    my $name = shift;
    return $name.'_created';
}



sub print_kobj {

    my ($proto, $host, $site_id) = @_;

    print <<EOF;
var KOBJ={
}

KOBJ.proto = \'$proto\'; 
KOBJ.host_with_port = \'$host\'; 
KOBJ.site_id = $site_id;

d = (new Date).getTime();

r=document.createElement("script");
r.src=KOBJ.proto+KOBJ.host_with_port+"/site/" + KOBJ.site_id + "/" + d + ".js";
r.src=r.src+"?";
r.src=r.src+"referer="+encodeURI(document.referrer) + "&";
r.src=r.src+"title="+encodeURI(document.title);
body=document.getElementsByTagName("body")[0];
body.appendChild(r);

EOF

}

sub debug_msg {

    return if(not $debug);

    my $label = shift;
    my $arg_str = join(', ',@_);


    $s->warn("$label: " . $arg_str);
}

