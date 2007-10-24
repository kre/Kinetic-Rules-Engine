package Apache::Kynetx;
# file: Apache/Kynetx.pm

use strict;
use warnings;


use XML::XPath;
use LWP::Simple;

use Kynetx::Rules qw(:all);;
# use Kynetx::Util qw(:all);;
use Kynetx::JavaScript qw(:all);




my $s = Apache2::ServerUtil->server;

my $debug = 0;

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
    $r->connection->remote_ip('128.122.108.71'); # new York (NYU)
#    $r->connection->remote_ip('72.21.203.1'); # Seattle

    # build initial env
    my $path_info = $r->path_info;
    my %global_env = (
	host => $r->connection->get_remote_host,
	referer => $r->headers_in->{'Referer'},
	now => time,
	site => $path_info =~ m#/(\d+)/.*\.js#,
	ip => $r->connection->remote_ip(),
	);

    if($debug) {
	foreach my $entry (keys %global_env) {
	    debug_msg($entry,  $global_env{$entry});
	}
    }

    # side effects environment with precondition pattern values
    my ($rules, $rule_env) = get_rule_set($global_env{'site'}, $global_env{'referer'});

    # this loops through the rules ONCE applying all that fire
    foreach my $rule (keys %{ $rules } ) {

	foreach my $var (keys %{ $rule_env } ) {
	    debug_msg("Env", "$var has value $rule_env->{$var}");
	}

	my $predicate = $rules->{$rule}->{'condition'}->{'predicate'};
	my $cond_args = $rules->{$rule}->{'condition'}->{'args'};
	

	if (&$predicate(\%global_env, $rule_env, $cond_args)) {

	    debug_msg("Firing the rule named", $rule);
	    
	    # this is the main event.  The browser has asked for a
	    # chunk of Javascrip and this is where we deliver... 
	    print mk_action($rules, \%global_env, $rule_env, $rule); 
	}
    }

}



sub mk_action {
    my ($rules, $req_info, $rule_env, $rule) = @_;
#    my ($action) = @_;

    my $action = $rules->{$rule}->{'action'};
    my $action_name = $rules->{$rule}->{'action'}->{'name'};


    # create comma separated list of arguments 
    my $arg_str = 
       join(',', 
	     gen_js_rands($rules->{$rule}->{'action'}->{'args'})) || '';


    # do we need to pass this in anymore?
    my $uniq = int(rand 999999999);

    $arg_str = '\'' . $uniq . '\', ' . $arg_str;
    my $id_str = 'kobj_'.$uniq; 
	    
    my $delay = $action->{'delay'} || 0;
    my $effect = $action->{'effect'} || '';

    debug_msg("Action", $action_name);
    debug_msg("Args", $arg_str);


    my $js = "";

    # set JS vars from rule env
    foreach my $var ( @{ get_precondition_vars($rules->{$rule}) } ) {
	debug_msg("Setting jS var for", $var);
	$js .= "var $var = \'" . $rule_env->{"$rule:$var"} . "\';\n";

    }

    $js .= gen_js_pre($req_info, $rule_env, $rules->{$rule}->{'pre'});


    # apply the action function
    $js .= "(". $actions{$action_name} . "(" . $arg_str . "));";


    if($action_name eq "float") {
	if($effect eq 'slide') {
	    $js .= "new Effect.toggle('" . $id_str . "', 'slide');"  ;
	} elsif($effect eq 'blind') {
	    $js .= "new Effect.toggle('" . $id_str . "', 'blind');"  ;
	} else {
	    $js .= "new Effect.toggle('" . $id_str . "', 'appear');"  ;
	}
	if($$action{'draggable'}) {
	    $js .= "new Draggable('". $id_str . "', '{ zindex: 99999 }');";
	}
	if($$action{'scrolls'}) {
	    $js .= "new FixedElement('". $id_str . "');";
	}
    } elsif($action_name eq "popup") {
	if ($effect eq 'onpageexit') {
	    my $funcname = "leave_" . $id_str;
	    $js = "function $funcname () { " . $js . "};\n";
	    $js .= "document.body.setAttribute('onUnload', '$funcname()');"
	}
    }

    

    if($delay) {
	# these ought to be pre-compiled on the rules
	$js =~ y/\n\r//d; # remove newlines
	$js =~ y/ //s;
	$js =~ s/'/\\'/g; # escape single quotes
	$js = "setTimeout(\'" . $js . "\', " . ($delay * 1000) . ")";
    }


    return $js . "\n\n";
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

