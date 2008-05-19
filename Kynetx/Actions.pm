package Kynetx::Actions;
# file: Kynetx/Actions.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Rules qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
$Data::Dumper::Indent = 1;


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
build_js_load
choose_action
eval_post_expr
get_precondition_test
get_precondition_vars
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my($active,$test,$inactive) = (0,1,2);

# TODO factor out common functionality in float and float2

# available actions
# should be a JS function; 
# mk_action will create a JS expression that applies it to appropriate arguments
# first arg MUST be uniq (a number unique to this rule action event)
# second arg MUST be cb (a callback function)
# note that $ is evaluated as a var indicator by perl in inlines.  Quote it.  
my %actions = (

    alert => <<EOF,
function(uniq, cb, msg) {alert(msg)}
EOF

#Actions::Alert::get_action(),

    redirect => 
      'function(uniq, cb, url) {window.location = url}',

    float_url => <<EOF,
function(uniq, cb, pos, top, side, url) {
   var id_str = 'kobj_'+uniq;
   var div = document.createElement('div');
   div.setAttribute('id', id_str);
   div.setAttribute('style', 'position: ' + pos + 
                    '; z-index: 9999;  ' +
                    top + '; ' + side + 
                    '; opacity: 0.999999; display: none');
   var div2 = document.createElement('div');
   var newtext = document.createTextNode('');
   div2.appendChild(newtext);
   div.appendChild(div2);
   document.body.appendChild(div);
   new Ajax.Updater(id_str, url, {
                    aynchronous: true,
                    method: 'get',
                    onComplete: cb
                   });
}
EOF


    float_html => <<EOF,
function(uniq, cb, pos, top, side, text) {
   var id_str = 'kobj_'+uniq;
   var div = document.createElement('div');
   div.setAttribute('id', id_str);
   div.setAttribute('style', 'position: ' + pos + 
                    '; z-index: 9999;  ' +
                    top + '; ' + side + 
                    '; opacity: 0.999999; display: none');
   var div2 = document.createElement('div');
   div2.innerHTML = text;
   div.appendChild(div2);
   document.body.appendChild(div);
   cb();
}
EOF

    popup => <<EOF,
function(uniq, cb, top, left, width, height, url) {      
    var id_str = 'kobj_'+uniq;
    var options = 'toolbar=no,menubar=no,resizable=yes,scrollbars=yes,alwaysRaised=yes,status=no' +
                 'left=' + left + ', ' +
                 'top=' + top + ', ' +
                 'width=' + width + ', ' +
                 'height=' + height;
    open(url,id_str,options);
    cb();
}
EOF

    replace_url => <<EOF,
function(uniq, cb, id, url) {
   id = \$(id);
   new Ajax.Updater(id, url, {
                    aynchronous: true,
                    method: 'get' ,
                    onComplete: cb
                    });   
   new Effect.Appear(id);
}
EOF

    replace_html => <<EOF,
function(uniq, cb, id, text) {
 var div = document.createElement('div');
 div.setAttribute('style', 'display: none');
 div.innerHTML = text;
 id = \$(id);
 id.replace(div);
 new Effect.BlindDown(div, {duration: 1.0});
 cb();
}
EOF

);


# function names in this hash indicate if the function is modifiable
my %modifiable = (
    'float_url' => 1,
    'float_html' => 1
    );



sub build_js_load {
    my ($rule, $req_info, $rule_env, $session) = @_;

    my $logger = get_logger();

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

    foreach my $action_expr (@{ $rule->{'actions'} }) {

	my $loop_js = '';

	my $action = $action_expr->{'action'};
	my $action_name = $action->{'name'};

	my $args = gen_js_rands( $action->{'args'} );


	# process overloaded functions and arg reconstruction
	($action_name, $args) = choose_action($req_info,$action_name,$args);

	# add to front of arg str
	unshift @{ $args }, $cb_func_name;
	unshift @{ $args }, mk_js_str($uniq);

	# create comma separated list of arguments 
	my $arg_str = join(',', @{ $args }) || '';

	$logger->debug("[action] ", $action_name, 
		       ' executing with args (',$arg_str,')');

	# apply the action function
	$loop_js .= "(". $actions{$action_name} . "(" . $arg_str . "));\n";

	push(@{ $rule_env->{'actions'} }, $action_name);

	# set defaults
	my %mods = (
	    delay => 0,
	    effect => 'appear',
	    scrollable => 0,
	    draggable => 0,
	    );

	# override defaults if set
	foreach my $m ( @{ $action->{'modifiers'} } ) {
	    $mods{$m->{'name'}} = gen_js_expr($m->{'value'});
	}


	if($modifiable{$action_name}) {
	    
	    $loop_js .= "new Effect.toggle('" . $id_str . "', ". $mods{'effect'} . " );"  ;

	    if($mods{'draggable'} eq 'true') {
		$loop_js .= "new Draggable('". $id_str . "', '{ zindex: 99999 }');";
	    }

	    if($mods{'scrollable'} eq 'true') {
		$loop_js .= "new FixedElement('". $id_str . "');";
	    }

	} elsif($action_name eq "popup") {
	    if ($mods{'effect'} eq 'onpageexit') {
		my $funcname = "leave_" . $id_str;
		$loop_js = "function $funcname () { " . $loop_js . "};\n";
		$loop_js .= "document.body.setAttribute('onUnload', '$funcname()');"
	    }
	}

	

	if($mods{'delay'}) {
	    # these ought to be pre-compiled on the rules
	    $loop_js =~ y/\n\r//d; # remove newlines
	    $loop_js =~ y/ //s;
	    $loop_js =~ s/'/\\'/g; # escape single quotes
	    $loop_js = "setTimeout(\'" . $loop_js . "\', " . ($mods{'delay'} * 1000) . ");";
	}

	push(@{ $rule_env->{'tags'} }, ($mods{'tags'} || ''));
	push(@{ $rule_env->{'labels'} }, $action_expr->{'label'} || '');

#	$logger->debug(Dumper($rule_env));


	# tack on this loop's js
	$js .= $loop_js;

    }

    return $js;
}


# some actions are overloaded depending on the args.  This function chooses 
# the right JS function and adjusts the arg string.
sub choose_action {
    my($req_info,$action_name,$args) = @_;
    my $logger = get_logger();

    my $action_suffix = "_url";

    if($action_name eq 'float' || $action_name eq 'replace') {

	my $last_arg = pop @$args;
	$logger->debug("[action] last arg is ", $last_arg);
    
	my $url = $last_arg;
	$url =~ s/'([^']*)'/$1/;

	$logger->debug("URL: ", $url);

	my $parsed_url = APR::URI->parse($req_info->{'pool'}, $url);
	my $parsed_caller = APR::URI->parse($req_info->{'pool'}, $req_info->{'caller'});

	# URL not relative and not equal to caller
	if ($parsed_url->hostname && 
	    ($parsed_url->hostname ne $parsed_caller->hostname ||
	     $parsed_url->port ne $parsed_caller->port ||
	     $parsed_url->scheme ne $parsed_caller->scheme)
	    ) {

	    $logger->debug("[action] URL is ", $parsed_url->hostname, 
			   " & caller is ", $parsed_caller->hostname);

	    $action_suffix = "_html";


	    # FIXME: should be caching this...
	    my $content = LWP::Simple::get($url);
	    $content =~ y/\n\r/  /; # remove newlines
	    $content =~ s/'/\\'/g; # quote quotes
	    $last_arg =  "'". $content . "'";
	    
	} 

	push @{ $args }, $last_arg;
    	$action_name = $action_name . $action_suffix;
    }

    $logger->debug("[action] $action_name with ", join(", ", @{$args}));

    return ($action_name, $args);
}



sub eval_post_expr {
    my($expr, $session) = @_;

    my $logger = get_logger();
    $logger->debug("[post] ", $expr->{'type'});

    my $js = '';
    case: for ($expr->{'type'}) {
	/clear/ && do { 
	    if(exists $expr->{'counter'}) {
		delete $session->{$expr->{'name'}};
		delete $session->{mk_created_session_name($expr->{'name'})}
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
		    $session->{mk_created_session_name($expr->{'name'})} = 
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


sub get_precondition_test {
    my $rule = shift;

    $rule->{'pagetype'}{'pattern'};
}

sub get_precondition_vars {
    my $rule = shift;

    $rule->{'pagetype'}{'vars'};
}


1;
