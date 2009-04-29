package Kynetx::Actions;
# file: Kynetx/Actions.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Rules qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
$Data::Dumper::Indent = 0;


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
function(uniq, cb, config, msg) {
    alert(msg);
    cb();
}
EOF

    redirect => <<EOF,
function(uniq, cb, config, url) {
    window.location = url;
    cb();
}
EOF

    # cb in load
    float_url => <<EOF,
function(uniq, cb, config, pos, top, side, src_url) {
    var d = KOBJ.buildDiv(uniq, pos, top, side);
    \$K(d).load(src_url, cb);
    \$K('body').append(d);
}
EOF


    float_html => <<EOF,
function(uniq, cb, config, pos, top, side, text) {
    var d = KOBJ.buildDiv(uniq, pos, top, side);
    \$K(d).html(text);
    \$K('body').append(d);
    cb();
}
EOF

    notify_six => <<EOF,
function(uniq, cb, config, pos, color, bgcolor, header, sticky, msg) {
  \$K.kGrowl.defaults.position = pos;
  \$K.kGrowl.defaults.background_color = bgcolor;
  \$K.kGrowl.defaults.color = color;
  \$K.kGrowl.defaults.header = header;
  \$K.kGrowl.defaults.sticky = sticky;
  if(typeof config === 'object') {
    jQuery.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(msg);
  cb();
}
EOF

    notify_two => <<EOF,
function(uniq, cb, config, header, msg) {
  \$K.kGrowl.defaults.header = header;
  if(typeof config === 'object') {
    jQuery.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(msg);
  cb();
}
EOF

    close_notification => <<EOF,
function(uniq, cb, config, selector) {
    KOBJ.close_notification(selector);
    cb();
}
EOF
    
    # cb passed into function
    annotate_search_results => <<EOF,
function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_search_results(annotate_fn, config, cb);
}
EOF


# not finished/tested
    catfish => <<EOF,
function(uniq, cb, config, msg) {
  var id_str = 'kobj_'+uniq;

  var message = \$K('<div>').addClass("CFmessage").css(
    {"position": "relative",
     "float": "left",
     "display": "block",
     "margin-top": "20px",
     "padding": "5px 5px 5px 5px",
     "font-size": "10px"
    }).html(msg);

  var close_button =
      \$K('<a></a>').css(
	  {"color": "rgb(30, 30, 30)",
	   "width": "20px"
	  }).click(function(){KOBJ.BlindUp('#'+id_str);false}).html("&times;");

  var closer = \$K('<div>').addClass("KOBJCatfish").css(
      {"margin": "20px 10px 0pt 25px",
       "padding": "0pt",
       "cursor": "pointer", 
       "float": "right",
       "font-size": "x-small"
      }).html(close_button);

  var catfish = \$K('<div>').attr('id','#'+id_str).css(
      {"position": "fixed", 
       "bottom": "0", 
       "left": "0pt",
       "background": "transparent url(http://frag.kobj.net/clients/images/bkAdBarBtm-greygrn.png) repeat-x left bottom", 
       "padding": "0",
       "height": "79px", 
       "z-index": "100", 
       "overflow": "hidden",
       "display": "none", 
       "width": "100%"
      }).append(closer).append(message);

  \$K('body').append(catfish);
  KOBJ.BlindDown('#KOBJ_catfish');
  cb();
}

EOF


    popup => <<EOF,
function(uniq, cb, config, top, left, width, height, url) {      
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

    # cb in load
    replace_url => <<EOF,
function(uniq, cb, config, id, src_url) {
    var d = document.createElement('div');
    \$K(d).css({display: 'none'}).load(src_url, cb);
    \$K('#'+id).replaceWith(d);
    \$K(d).slideDown('slow');
}
EOF

    # need new "effects" model
    replace_html => <<EOF,
function(uniq, cb, config, id, text) {
 var div = document.createElement('div');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K('#'+id).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
EOF

    move_after => <<EOF,
function(uniq, cb, config, anchor, item) {
    var i = '#'+item;
    \$K('#'+anchor).after(\$K(i));
    cb();
}
EOF
    
    move_to_top => <<EOF,
function(uniq, cb, config, li) {
    li = '#'+li;
    \$K(li).siblings(':first').before(\$K(li));
    cb();
}
EOF

    replace_image_src => <<EOF,
function(uniq, cb, config, id, new_url) {
    \$K('#'+id).attr('src',new_url);
    cb();
}
EOF

    noop => <<EOF,
function(uniq, cb, config) {
    cb();
}
EOF

# FIXME: not done with this
    log_callback => <<EOF,
function(uniq, cb, config) {
    KOBJ.logger("click",
		txn_id,
		name, 
	        '', 
		sense,
		rule
	);
    false;
    }
    cb();
EOF

);




sub emit_var_decl {
    my($lhs, $val) = @_;
    my $t = infer_type($val);
    if($t eq 'str') {
	$val = "'".escape_js_str($val)."'";
	# relace tmpl vars with concats for JS
	$val =~ s/#{([^}]*)}/'+$1+'/g;
    } elsif ($t eq 'hash' || $t eq 'array') {
	$val = encode_json($val);
    }
    my $logger = get_logger();
    $logger->debug("[decl] $lhs has type: $t");
    return "var $lhs = $val;\n";

}


sub build_js_load {
    my ($rule, $req_info, $rule_env, $session) = @_;

    my $logger = get_logger();

    # rule id
    my $uniq = int(rand 999999999);
    my $uniq_id = 'kobj_'.$uniq; 


    $rule_env->{'uniq_id'} = $uniq_id;


# do this in Rule.pm  now that the pre can set vars that are used in cond
    # this loads the rule_env
#    eval_js_pre($req_info, $rule_env, $rule->{'name'}, $session, $rule->{'pre'});


    my $js = "";

    
    # set JS vars from rule env
#     my $rulename_re = qr/^$rule->{'name'}:(.*)/;
#     foreach my $var ( keys %{ $rule_env} ) {
# 	my $val = $rule_env->{$var};
# 	next unless $var =~ s/$rulename_re/$1/;
# 	$logger->debug("[JS var] ", $var, "->", $val);
# 	$js .= emit_var_decl($var,$val);

#     }

    $logger->debug("Rule ENV: ", sub {my $f = Dumper($rule_env);$f =~ y/\n//d;return $f});

    $logger->debug("Rule name: ", $rule->{'name'});
    # now do decls in order
    foreach my $var( @{ $rule_env->{$rule->{'name'}."_vars"} } ) {
	$js .= emit_var_decl($var, $rule_env->{$rule->{'name'}.":$var"});
    }

    # emits
    $js .= $rule->{'emit'} . "\n" if(defined $rule->{'emit'});


    # callbacks
    my $cb = '';
    if($rule->{'callbacks'}) {
	foreach my $sense ('success','failure') {
	    $cb .= gen_js_callbacks($rule->{'callbacks'}->{$sense},
				    $req_info->{'txn_id'},
		                    $sense,
				    $rule->{'name'}
		                   );
	}
    }
    
    my $cb_func_name = 'callBacks'.$uniq;
    $js .= gen_js_mk_cb_func($cb_func_name,$cb);


    my $action_num = int(@{ $rule->{'actions'} });

    $logger->debug('blocktype is ' . $rule->{'blocktype'});
    $logger->debug("actions list contains $action_num actions");
    if ($rule->{'blocktype'} eq 'every') {
	# generate JS for every action
	foreach my $action_expr (@{ $rule->{'actions'} }) {
	    # tack on this loop's js
	    if(defined $action_expr->{'action'}) {
		$js .= build_one_action($action_expr, 
					$req_info, 
					$rule_env, 
					$session,
					$uniq,
					$uniq_id,
					$cb_func_name,
					$rule->{'name'}
		    );
	    } elsif(defined $action_expr->{'emit'}) {
		$js .= $action_expr->{'emit'}. ";\n";
		$js .= "$cb_func_name();\n";
		push(@{ $rule_env->{'actions'} }, 'emit');
		push(@{ $rule_env->{'tags'} }, '');
		push(@{ $rule_env->{'labels'} }, $action_expr->{'label'});

	    }
	}

    } elsif ($rule->{'blocktype'} eq 'choose') {
	# choose one action at random
	my $choice = int(rand($action_num));
	$logger->debug("chose $choice of $action_num");
	$js .= build_one_action($rule->{'actions'}->[$choice], 
				$req_info, 
				$rule_env, 
				$session,
				$uniq,
				$uniq_id,
				$cb_func_name,
				$rule->{'name'}
	    );

    } else {
	$logger->debug('bad blocktype');
    }

    return $js;

}


sub build_one_action {
    my ($action_expr, $req_info, $rule_env, $session, 
	$uniq, $uniq_id, $cb_func_name, $rule_name) = @_;

    my $logger = get_logger();


    my $js = '';

    my $action = $action_expr->{'action'};
    my $action_name = $action->{'name'};

    my $args = $action->{'args'};

    # process overloaded functions and arg reconstruction
    ($action_name, $args) = 
	choose_action($req_info, $action_name, $args, $rule_env, $rule_name);

    # this happens after we've chosen the action since it modifies args
    $args = gen_js_rands( $args );

    # set defaults
    my %mods = (
	delay => 0,
	effect => 'appear',
	scrollable => 0,
	draggable => 0,
	);

    my @config = ("txn_id: '".$req_info->{'txn_id'} . "'", "rule_name: '$rule_name'");

    # override defaults if set
    foreach my $m ( @{ $action->{'modifiers'} } ) {
	$mods{$m->{'name'}} = gen_js_expr($m->{'value'});
#	$logger->debug(sub {Dumper($m)} );

	push(@config, "'" . $m->{'name'} . "':" . 
 	               gen_js_expr(eval_js_expr($m->{'value'}, 
						$rule_env, 
						$rule_name, 
						$req_info, 
						$session)));
    }


    # add to front of arg str (in reverse)
    unshift @{ $args }, '{' . join(",", @config) . '}';
    unshift @{ $args }, $cb_func_name;
    unshift @{ $args }, mk_js_str($uniq);

    # create comma separated list of arguments 
    my $arg_str = join(',', @{ $args }) || '';

    $logger->debug("[action] ", $action_name, 
		   ' executing with args (',$arg_str,')');

    # apply the action function
    $js .= "(". $actions{$action_name} . "(" . $arg_str . "));\n";

    push(@{ $rule_env->{'actions'} }, $action_name);



    # function names in this hash indicate if the function is modifiable
    # FIXME: this isn't a good way to map effects to actions
    my %modifiable = (
	'float_url' => 1,
	'float_html' => 1,
#	'replace_url' => 1,
#	'replace_html' => 1,
	);


    if($modifiable{$action_name}) {
	# map our effect names to Sript.taculo.us effect names

	my $effect_name;
        case: for ($mods{'effect'}) {
	    /appear/ && do {
		$effect_name = 'fadeIn';
	    };
	    /slide/ && do {
		$effect_name = 'slideDown';
	    };
	    /blind/ && do {
		$effect_name = 'slideDown';
	    };
	}


	$logger->debug("Using effect $effect_name for $mods{'effect'}");
	$js .= "\$K('#$uniq_id').$effect_name();"  ;

	if($mods{'draggable'} eq 'true') {
	    $js .= "\$K('#$uniq_id').draggable();";
	}
	
	if($mods{'scrollable'} eq 'true') {
	    # do nothing
#	    $js .= "new FixedElement('". $uniq_id . "');";
	}

	if($mods{'highlight'}) {
	    my $color = '#ffff99';
 	    case: for ($mods{'highlight'}) {
		/yellow/ && do {
		    $color = '#ffff99';
		};
		/pink/ && do {
		    $color = '#ff99ff';
		};
		/purple/ && do {
		    $color = '#99ffff';
		};
		/#[A-F0-9]{6}/ && do {
		    $color = $mods{'highlight'};
		}
	    }
	    
#	    $js .= "new Effect.Highlight('$uniq_id', {startcolor: '$color', });"  ;
	}



    } elsif($action_name eq "popup") {
	if ($mods{'effect'} eq 'onpageexit') {
	    my $funcname = "leave_" . $uniq_id;
	    $js = "function $funcname () { " . $js . "};\n";
	    $js .= "document.body.setAttribute('onUnload', '$funcname()');"
	}
    }

	
    if($mods{'delay'}) {

	my $delay_cb = 
	     ";KOBJ.logger('timer_expired', '" .
	                  $req_info->{'txn_id'} . "'," .
		          "'none', '', 'success', '" .
			  $rule_name .
                          "');";

	$js .= $delay_cb;  # add in automatic log of delay expiration
	
	$js = "setTimeout(function() { $js },  ($mods{'delay'} * 1000) ); \n";

#	$js = "setTimeout(\'" . $js . "\', " . ($mods{'delay'} * 1000) . ");\n";
    }

    push(@{ $rule_env->{'tags'} }, ($mods{'tags'} || ''));
    push(@{ $rule_env->{'labels'} }, $action_expr->{'label'} || '');

#	$logger->debug(sub {Dumper($rule_env)} );

    return $js;
}


# some actions are overloaded depending on the args.  This function chooses 
# the right JS function and adjusts the arg string.
sub choose_action {
    my($req_info,$action_name,$args,$rule_env,$rule_name) = @_;
    my $logger = get_logger();

    my $action_suffix = "_url";

    if($action_name eq 'float' || $action_name eq 'replace') {

	my $last_arg = pop @$args;

	my $url = gen_js_expr($last_arg);
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

	    $logger->debug("[action] URL domain is ", $parsed_url->hostname, 
			   " & caller domain is ", $parsed_caller->hostname
		);

	    $action_suffix = "_html";


#	    $logger->debug("Rule env: ", sub { Dumper($rule_env) });
	    
	    # We need to eval the argument since it might be an expression
	    $url = den_to_exp(
		    eval_js_expr($last_arg, $rule_env, $rule_name,$req_info));
#	    $url =~ s/^'(.*)'$/$1/;
	    $logger->debug("Fetching ", $url);

	    # FIXME: should be caching this...
	    my $content = LWP::Simple::get($url) || "<!-- URL $url returned no content -->";
	    $content =~ y/\n\r/  /; # remove newlines
	    $last_arg =  Kynetx::Parser::mk_expr_node('str',$content);
	    #$logger->debug("Last arg: ", sub { Dumper($last_arg) });
	    
	} 

	push @{ $args }, $last_arg;
    	$action_name = $action_name . $action_suffix;
    } elsif($action_name eq 'notify') {
	if(scalar @{ $args} == 2) {
	    $action_name = 'notify_two';
	} else {
	    $action_name = 'notify_six';
	}
    }

#    $logger->debug("[action] $action_name with ", 
#		   sub { join(", ", Dumper(@{$args}))});

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

	    # what the heck is this doing????
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
