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
#    $r->connection->remote_ip('128.122.108.71'); # new York (NYU)
#    $r->connection->remote_ip('72.21.203.1'); # Seattle (Amazon)
    $r->connection->remote_ip('128.187.16.242'); # Utah (BYU)



    # build initial env
    my $path_info = $r->path_info;
    my %request_info = (
	host => $r->connection->get_remote_host,
	caller => $r->headers_in->{'Referer'},
	now => time,
	site => $path_info =~ m#/(\d+)/.*\.js#,
	ip => $r->connection->remote_ip(),
	);
    
    # we're going to process our own params
    foreach my $arg (split('&',$r->args())) {
	my ($k,$v) = split('=',$arg);
	$request_info{$k} = $v;
	$request_info{$k} =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    }
    

    if($debug) {
	foreach my $entry (keys %request_info) {
	    debug_msg($entry,  $request_info{$entry});
	}
    }

    # side effects environment with precondition pattern values
    my ($rules, $rule_env) = get_rule_set($request_info{'site'}, $request_info{'caller'});

    # this loops through the rules ONCE applying all that fire
    foreach my $rule ( @{ $rules } ) {

	foreach my $var (keys %{ $rule_env } ) {
	    debug_msg("Env", "$var has value $rule_env->{$var}");
	}


	debug_msg("Eval", "Executing $rule->{'name'}");

	my $conds = $rule->{'cond'};
	my $pred_value = 1;
	foreach my $cond ( @$conds ) {
	    my $pred = $cond->{'predicate'};
	    my $predf = $Kynetx::Rules::predicates{$pred};

	    my @args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

	    debug_msg('Predicate',
		"$pred executing with args(" . join(', ', @args ) . ')');

	    my $v = &$predf(\%request_info, 
			    $rule_env, 
			    \@args
		           );

	    debug_msg("Pred", "$cond->{'predicate'} returns $v");

	    $pred_value = $pred_value && $v;
	}


	if ($pred_value) {

	    debug_msg("Firing the rule named", $rule->{'name'});
	    
	    # this is the main event.  The browser has asked for a
	    # chunk of Javascrip and this is where we deliver... 
	    print mk_action($rule, \%request_info, $rule_env); 
	} else {
	    debug_msg("Rule did not fire",  $rule->{'name'});
	}
    }

}



sub mk_action {
    my ($rule, $req_info, $rule_env) = @_;
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

    debug_msg("Action", $action_name);
    debug_msg("Args", $arg_str);


    my $js = "";

    # set JS vars from rule env
    foreach my $var ( @{ get_precondition_vars($rule) } ) {
	debug_msg("Setting jS var for", $var);
	$js .= "var $var = \'" . $rule_env->{"$rule->{'name'}:$var"} . "\';\n";

    }

    $js .= gen_js_pre($req_info, $rule_env, $rule->{'pre'});


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

