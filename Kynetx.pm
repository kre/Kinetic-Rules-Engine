package Kynetx;
# file: Kynetx.pm

use strict;
use warnings;


use XML::XPath;
use LWP::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);


use Kynetx::Rules qw(:all);;
use Kynetx::Util qw(:all);;
use Kynetx::JavaScript qw(:all);


my $logger;
$logger = get_logger();

if($logger->is_debug()) {

    use Data::Dumper;
}


my $s = Apache2::ServerUtil->server;

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');

# read in some params from the httpdconf file
#    $debug = $r->dir_config('debug');

    process_rules($r);

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

    my $cookie = $r->headers_in->{'Cookie'};
    $cookie =~ s/SESSION_ID=(\w*)/$1/ if(defined $cookie);


    my %session;
    tie %session, 'Apache::Session::DB_File', $cookie, {
	FileName      => '/web/data/sessions.db',
	LockDirectory => '/web/lock/sessions',
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

    $logger->info("Processing rules for site " . $request_info{'site'});

    if($logger->is_debug()) {
	foreach my $entry (keys %request_info) {
	    $logger->debug($entry . ": " . $request_info{$entry});
	}
    }

    # side effects environment with precondition pattern values
    my ($rules, $rule_env) = get_rule_set($request_info{'site'}, $request_info{'caller'},$r->dir_config('svn_conn'));

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
	    $js .= mk_action($rule, \%request_info, $rule_env, \%session); 

	    $js .= eval_post_expr($cons, \%session) if(defined $cons);

	} else {
	    $logger->info("did not fire");

	    $js .= eval_post_expr($alt, \%session) if(defined $alt);


	}

	# return the JS load to the client
	print $js; 
	$logger->info("finished");
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


    my $id_str = 'kobj_'.$uniq; 


    my $js = "";

    # set JS vars from rule env
    foreach my $var ( @{ get_precondition_vars($rule) } ) {
	my $val = $rule_env->{"$rule->{'name'}:$var"};
	$logger->debug("[JS var] ", $var, "->", $val);
	$js .= "var $var = \'" . $val . "\';\n";

    }


    $js .= gen_js_pre($req_info, $rule_env, $session, $rule->{'pre'});


    # callbacks
    my $cb = '';
    if($rule->{'callbacks'}) {
	foreach my $sense ('success','failure') {
	    $cb .= gen_js_callbacks($rule->{'callbacks'}->{$sense},
		                    $sense,
				    $rule->{'name'}
		                   );
	}
    }
    
    # wrap up in load
#    $cb = gen_js_afterload($cb);
    my $cb_func_name = 'callBacks'.$uniq;
    $js .= gen_js_mk_cb_func($cb_func_name,$cb);

    # add to arg str
    $arg_str = join(',',
		    mk_js_str($uniq),
		    $cb_func_name,
		    $arg_str);

    $logger->debug("[action] ", $action_name, 
		                 ' executing with args (',$arg_str,')');

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



    return $js;
}


sub eval_predicates {
    my($request_info, $rule_env, $session, $rule) = @_;

    my $conds = $rule->{'cond'};
    my $pred_value = 1;
    foreach my $cond ( @$conds ) {
	my $v;
	if ($cond->{'type'} eq 'simple') {
	    my $pred = $cond->{'predicate'};
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

	} elsif ($cond->{'type'} eq 'counter') {

	    my $name = $cond->{'name'};

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

		$v = $v && after_now($desired);
	    }


	}

	$pred_value = $pred_value && $v;
    }
    return $pred_value;
}

sub eval_post_expr {
    my($expr, $session) = @_;

    $logger->debug("[post] ", $expr->{'type'});

    my $js = '';
    case: for ($expr->{'type'}) {
	/clear/ && do { 
	    if(exists $expr->{'counter'}) {
		delete $session->{$expr->{'name'}};
		delete $session->{add_created($expr->{'name'})}
	    }
	    return $js;
	};
	/iterator/ && do {
	    if(exists $expr->{'counter'}) {
		if(exists $session->{$expr->{'name'}}) {
		    $session->{$expr->{'name'}} += $expr->{'value'};
		    $logger->debug("[post] iterating counter ",  
				   $expr->{'name'},
				   " by ",
				   $expr->{'value'});

		} else {
		    $session->{$expr->{'name'}} = $expr->{'from'};
		    $session->{add_created($expr->{'name'})} = 
			# use DateTime for consistency 
			DateTime->now->epoch;
		    $logger->debug("[post] initializing counter ",  
				   $expr->{'name'},
				   " to ",
				   $expr->{'from'});
		}
	    }
	    return $js;
	};

	/callbacks/ && do {

	    foreach my $cb (@{$expr->{'callbacks'}}) {
		my $t = $cb->{'value'};
		my $a = $cb->{'attribute'};
		$session->{$t} = 1;
		$logger->debug("[post] Setting callback named $a = $t");
		if($a eq 'id') {
		    $js .= <<EJS;
var e_$t = document.getElementById('$t');  
Event.observe(e_$t, "click", function() {KOBJ.logger("$t")});
EJS
		} elsif ($a eq 'class') {
		    $js .= <<EJS1;
var e_$t = document.getElementsByClass('$t');  
e_$t.each(function (c) {
    Event.observe(c, "click", function() {KOBJ.logger("$t")})});
EJS1
	        } 
	    }
	    return $js;
	};
    }

}

sub add_created {
    my $name = shift;
    return $name.'_created';
}



