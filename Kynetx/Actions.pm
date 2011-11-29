package Kynetx::Actions;

# file: Kynetx/Actions.pm
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::JavaScript::AST;
use Kynetx::Expressions qw(:all);
use Kynetx::Rules;
use Kynetx::Environments qw(:all);
use Kynetx::Session q/:all/;
use Kynetx::Log q/:all/;
use Kynetx::Json q/:all/;
use Kynetx::Rids q/:all/;
use Kynetx::Modules::Twitter;
use Kynetx::Modules::PDS;
use Kynetx::Actions::LetItSnow;
use Kynetx::Actions::JQueryUI;
use Kynetx::Actions::Annotate;
use Kynetx::Actions::FlippyLoo;
use Kynetx::Actions::Email;
use Kynetx::Directives qw/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
$Data::Dumper::Indent = 0;

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
	all => [
		qw(
		  build_js_load
		  choose_action
		  )
	]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

my ( $active, $test, $inactive ) = ( 0, 1, 2 );
my $f = 0;

# FIXME factor out common functionality in float and float2

# available actions
# can be simply a JS function;
# mk_action will create a JS expression that applies it to appropriate arguments
# first arg MUST be uniq (a number unique to this rule action event)
# second arg MUST be cb (a callback function)
# note that $ is evaluated as a var indicator by perl in inlines.  Quote it.

# can alternately be a hash
#   'js' is the JS to be included
#   'before' is a function of five args to be executed before the action's JS
#       is included ($req_info,$rule_env,$session,$config,$mods)
#       returns JS
#   'after' is an array of functions to be executed in order after the
#       action's JS.  Same args as 'before' except first additional arg is
#       the existing JS.  It's replaced with the final result of the chain.
#   'before' and 'after' are both optional

my $default_actions = {

	alert => {
		'js' => <<EOF,
function(uniq, cb, config, msg) {
    alert(msg);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},
	page_content => {
		'js' => <<EOF,
	function(uniq, cb, config, label, selectors) {
	    KOBJ.page_content_event(uniq, label, selectors ,config);
	    cb();
	}
EOF
		'after' => [ \&handle_delay ]
	},
	raise_event => {
		'js' => <<EOF,
	function(uniq, cb, config, event_name) {
	    KOBJ.raise_event_action(uniq, event_name ,config);
	    cb();
	}
EOF
		'after' => [ \&handle_delay ]
	},
	content_changed => {
		'js' => <<EOF,
	function(uniq, cb, config, selector) {
          var app = KOBJ.get_application(config.rid);
          if(config.parameters)
            KOBJEventManager.register_interest("content_change",selector,app,{"param_data" : config.parameters });
          else
            KOBJEventManager.register_interest("content_change",selector,app);
	    cb();
	}
EOF
		'after' => [ \&handle_delay ]
	},
	page_collection_content => {
		'js' => <<EOF,
	function(uniq, cb, config, label, top_selector, parent_selector, selectors) {
	    KOBJ.page_collection_content_event(uniq, label,top_selector, parent_selector, selectors ,config);
	    cb();
	}
EOF
		'after' => [ \&handle_delay ]
	},

	redirect => {
		'js' => <<EOF,
function(uniq, cb, config, url) {
    window.location = url;
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	# cb in load
	float_url => {
		'js' => <<EOF,
function(uniq, cb, config, pos, top, side, src_url) {
    var d = KOBJ.buildDiv(uniq, pos, top, side,config);
    \$K(d).load(src_url, cb);
    \$K('body').append(d);
}
EOF
		'after' => [ \&handle_effects, \&handle_delay ]
	},

	float_html => {
		'js' => <<EOF,
function(uniq, cb, config, pos, top, side, text) {
    var d = KOBJ.buildDiv(uniq, pos, top, side,config);
    \$K(d).html(text);
    \$K('body').append(d);
    cb();
}
EOF
		'after' => [ \&handle_effects, \&handle_delay ]
	},

	notify_six => {
		'js' => <<EOF,
function(uniq, cb, config, pos, color, bgcolor, header, sticky, msg) {
  \$K.kGrowl.defaults.position = pos;
  \$K.kGrowl.defaults.background_color = bgcolor;
  \$K.kGrowl.defaults.color = color;
  \$K.kGrowl.defaults.header = header;
  \$K.kGrowl.defaults.sticky = sticky;
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(msg);
  cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	notify_two => {
		'js' => <<EOF,
function(uniq, cb, config, header, msg) {
	if(typeof config != 'object')
   {
 	config = {header : header};
   }
else
{
 	\$K.extend(config,{header : header});
}
   \$K.kGrowl(msg,config);
  cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	close_notification => <<EOF,
function(uniq, cb, config, selector) {
    KOBJ.close_notification(selector);
    cb();
}
EOF

	# cb passed into function
	annotate_search_results => {
		'js' => <<EOF,
function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_search_results(annotate_fn, config, cb);
}
EOF
		'after' => [ \&handle_delay ]
	},

	annotate_local_search_results => {
		'js' => <<EOF,
function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_local_search_results(annotate_fn, config, cb);
}
EOF
		'after' => [ \&handle_delay ]
	},

	percolate => {
		'js' => <<EOF,
function(uniq,cb,config,sel) {
    KOBJ.percolate(sel,config);
}
EOF
		'after' => [ \&handle_delay ]
	},

	popup => {
		'js' => <<EOF,
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

		# in truth these are mutually exclusive...how to handle...
		'after' => [ \&handle_popup, \&handle_delay ]
	},

	# cb in load
	replace_url => {
		'js' => <<EOF,
function(uniq, cb, config, sel, src_url) {
    var d = \$K('<div>');
    \$K(d).css({display: 'none'}).load(src_url, cb);
    \$K(sel).replaceWith(d);
    \$K(d).slideDown('slow');
}
EOF
		'after' => [ \&handle_delay ]
	},

	# need new "effects" model
	replace_html => {
		'js' => <<EOF,
function(uniq, cb, config, sel, text) {
 var div = \$K('<div>');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K(sel).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	# need new "effects" model
	replace_inner => {
		'js' => <<EOF,
function(uniq, cb, config, sel, text) {
 \$K(sel).html(text);
 cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	move_after => {
		'js' => <<EOF,
function(uniq, cb, config, anchor, item) {
    var i = item;
    \$K(anchor).after(\$K(i));
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	move_to_top => {
		'js' => <<EOF,
function(uniq, cb, config, li) {
    \$K(li).siblings(':first').before(\$K(li));
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	replace_image_src => {
		'js' => <<EOF,
function(uniq, cb, config, id, new_url) {
    \$K(id).attr('src',new_url);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	noop => {
		'js' => <<EOF,
function(uniq, cb, config) {
    cb();
}
EOF
		'after' => [ \&handle_delay ],
	},

	before => {
		'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).before(content);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	after => {
		'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).after(content);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	append => {
		'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).append(content);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},
	prepend => {
		'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).prepend(content);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	sidetab => {
		'js' => <<EOF,
function(uniq, cb, config) {
    KOBJ.tabManager.addNew(config);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	status_bar => {
		'js' => <<EOF,
function(uniq, cb, config, content) {
    KOBJ.statusbar(config, content);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	'watch' => {
		'js' => <<EOF,
function(uniq, cb, config, element, type) {
    KOBJ.watch_event(type, element, config);
    cb();
}
EOF
		'after' => []
	},

	let_it_snow => {
		'js' => <<EOF,
function(uniq, cb, config) {
	KOBJ.letitsnow(config);
	cb();
}
EOF
		'after' => [ \&handle_delay ]

	},

	set_form_maps => {
		'js' => <<EOF,
function(uniq, cb, config, map) {
    KOBJ.setFormMaps(map,config);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},

	fill_forms => {
		'js' => <<EOF,
function(uniq, cb, config, data) {
    KOBJ.fillForms(data,config);
    cb();
}
EOF
		'after' => [ \&handle_delay ]

	},
	set_element_attr => {
		'js' => <<EOF,
function(uniq, cb, config, selector, attr,value) {
    \$K(selector).attr(attr,value);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},
	remove => {
		'js' => <<EOF,
function(uniq, cb, config, selector) {
    \$K(selector).remove();
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},
	click => {
		'js' => <<EOF,
function(uniq, cb, config, selector, func) {
    var myfunc = eval("(" + func + ")");
    \$K(selector).click(myfunc);
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},
	jsfunction => {
		'js' => <<EOF,
function(uniq, cb, config,name, func) {
    var myfunc = eval("(" + func + ")");
    window[name] = myfunc;
    cb();
}
EOF
		'after' => [ \&handle_delay ]
	},
	send_directive => {
		directive => sub {
			my $req_info = shift;
			my $dd = shift;
			my $config   = shift;
			my $args     = shift;
			send_directive($req_info, $dd, $args->[0], $config );
		},
	},
};

sub build_js_load {
	my ( $rule, $req_info, $dd, $rule_env, $session ) = @_;

	my $logger = get_logger();

	my $js = "";

	# emits
	$js .= eval_emit( $rule->{'emit'} ) . "\n" if ( defined $rule->{'emit'} );

	# callbacks
	my $cb = '';
	if ( $rule->{'callbacks'} ) {
		$logger->debug("Has callbacks");
		foreach my $sense ( 'success', 'failure' ) {
			$cb .= gen_js_callbacks( $rule->{'callbacks'}->{$sense},
				$req_info->{'txn_id'}, $sense, $rule->{'name'},
				get_rid($req_info->{'rid'}) );
		}
	}

	my $cb_func_name = 'callBacks';
	$js .= Kynetx::JavaScript::gen_js_mk_cb_func( $cb_func_name, $cb );

	# Break out the action block functionality
	$logger->trace("Action block: ", sub {Dumper($rule->{'actions'})});
	
	$js .= eval_action_block(
		$req_info,
		$dd,
		$rule_env,
		$session,
		$rule->{'blocktype'},
		$rule->{'actions'},
		$rule->{'name'},
		$cb_func_name
               );

	return $js;

}

sub eval_action_block {
	my ($req_info, $dd, $rule_env,$session, $blocktype,$action_block,$rulename,$cb_function) = @_;
	my $logger = get_logger();	
	my $js = "";
	
	# if it's null, we want an empty list
	$action_block ||= [];

	my $action_num = int( @{ $action_block } );

	$logger->debug( "blocktype is [$blocktype]"  );
	$logger->debug("actions list contains $action_num actions");
	if ( $blocktype eq 'every' ) {

		# generate JS for every action
		foreach my $action_expr ( @{ $action_block } ) {

			# tack on this loop's js
			if ( defined $action_expr->{'action'} ) {
				$js .=
				  build_one_action( $action_expr, $req_info, $dd, $rule_env,
					$session, $cb_function, $rulename );
			}
			elsif ( defined $action_expr->{'emit'} ) {
				$logger->debug("EMIT action");
				$js .= $action_expr->{'emit'} . ";\n";
				$js .= "$cb_function();\n";
				push( @{ $req_info->{'actions'} }, 'emit' );
				push( @{ $req_info->{'tags'} },    '' );
				push( @{ $req_info->{'labels'} },  $action_expr->{'label'} );

			}
		}

	}
	elsif ( $blocktype eq 'choose' ) {

		# choose one action at random
		my $choice = int( rand($action_num) );
		$logger->debug("chose $choice of $action_num");
		$js .= build_one_action( $action_block->[$choice],
			$req_info, $dd, $rule_env, $session, $cb_function, $rulename);

	}
	else {
		$logger->debug('bad blocktype');
	}
	return $js;
}

sub build_composed_action {
	my ($source,$name,$orig_env, $rule_env,$req_info, $dd, $session,$args,$modifiers,$rule_name, 
			$cb_func_name) = @_;
	my $logger = get_logger();
	my $action_tag;
	my $js = "";
		
	my $config_array = $rule_env->{'configure'};	
	my $decls = $rule_env->{'decls'};
	my $actions = $rule_env->{'actions'};
	my $blocktype = $rule_env->{'blocktype'};
	my $required = $rule_env->{'vars'};
	$rule_env = $rule_env->{'env'};
	
	
	$logger->trace("Configuration: ", sub {Dumper($config_array)});
	if ($source) {
		$action_tag = $source . ":" . $name;
	} else {
		$action_tag = $name;
	}
	
	# Composed action requires arguments
	my $psize = scalar(@$args);
	my $rsize = scalar(@$required);
	
	if ($psize < $rsize) {
		return gen_js_error("$action_tag requires $rsize arguments, you passed ($psize)");
	}
	$rule_env = extend_rule_env($required,$args,$rule_env);
	
	$rule_env = Kynetx::Rules::set_module_configuration($req_info,
		$orig_env,
		$session,
		$rule_env,
		$config_array,
		$modifiers);
		
	#$logger->debug("After Module Configuration: ",sub {Dumper($rule_env)});

	my $srid = get_rid($req_info->{'rid'});
	my $orid = Kynetx::Environments::lookup_rule_env("ruleset_name",$orig_env);
	my $crid = Kynetx::Environments::lookup_rule_env("ruleset_name",$rule_env);


	# decls are stored in a composable action
	foreach my $decl (@$decls) {

	  $logger->debug("Evaling action declaration $decl->{'lhs'} for $name");
	  $logger->trace("Found decl: ", sub { Dumper($decl)});
	  my $d = Kynetx::Expressions::eval_one_decl($req_info,$rule_env,$action_tag,$session,$decl);
	  $logger->trace("Declaration: $d");
	  $js .= $d;
	}

	my $rcount = $req_info->{"__recursion__"} || 0;
	
	if ($rcount > Kynetx::Expressions::recursion_threshold()) {
		
		return "{ // Deep recursion exception
			}";
	}	
	if (defined $srid && defined $crid && $srid eq $crid) {
		$rcount++;
		$logger->trace("Rids are the same!-----------------------");
		$req_info->{"__recursion__"} = $rcount;
	}
	
	my @action_block = ();	
	foreach my $action (@$actions) {
		$logger->trace("Action array element ",sub {Dumper($action)});
		push(@action_block,Kynetx::Expressions::eval_action($action,$rule_env, $rule_name, $req_info, $session));
	}
	$js .= eval_action_block(
		$req_info,
	        $dd,
		$rule_env,
		$session,
		$blocktype,
		\@action_block,
		$rule_name,
		$cb_func_name);
		
	return $js;
}


sub build_one_action {
	my (
		$action_expr, $req_info,     $dd, $rule_env,
		$session,     $cb_func_name, $rule_name
	) = @_;

	my $logger = get_logger();
	$logger->trace( "Build one action: ",sub {Dumper($action_expr)});

	my $uniq    = int( rand 999999999 );
	my $uniq_id = 'kobj_' . $uniq;

#    $rule_env = extend_rule_env(['uniq_id', 'uniq'], [$uniq_id,$uniq], $rule_env);
	$req_info->{'uniq'}    = $uniq;
	$req_info->{'uniq_id'} = $uniq_id;

	my $js = '';

	my $action      = $action_expr->{'action'};
	my $action_name = $action->{'name'};

	my $args = $action->{'args'};
#	$logger->debug( "Build one action args: ",sub {Dumper($args)});

	# parse the action args and make the expressed values
	my $arg_den_vals = []; # all the denoted vals
	my $arg_action_vals = []; # all the denoted vals unless it's a var
	my $arg_exp_vals = []; # all the expressed vals 
	foreach my $arg ( @{$args} ) {
	  my $val = Kynetx::Expressions::eval_expr( $arg, 
	              $rule_env, $rule_name, $req_info,
		      $session );
	  push(@{$arg_den_vals}, $val);

	  if ($arg->{'type'} eq 'var') {
	    push(@{$arg_action_vals}, $arg);
	  } else {
	    push(@{$arg_action_vals}, $val);
	  }

	  push(@{$arg_exp_vals}, Kynetx::Expressions::den_to_exp($val));

	}

#	$logger->debug( "Build one action arg denoted vals: ",sub {Dumper($arg_den_vals)});

#	$logger->debug( "Build one action arg exp vals: ",sub {Dumper($arg_exp_vals)});

	# process overloaded functions and arg reconstruction
	( $action_name, $args ) =
	  choose_action( $req_info, $dd, $action_name, $arg_action_vals, $rule_env, $rule_name, $args );

	# this happens after we've chosen the action since it modifies args

#	$logger->debug("Args before conversion to JS: ", sub { Dumper $args});

	$args = Kynetx::JavaScript::gen_js_rands($args);	

#	$logger->debug("Args after conversion to JS: ", sub { Dumper $args});


	# Check for composable action before any other built-ins
	my $defaction;
	if (defined $action->{'source'}) {
		$defaction = Kynetx::Modules::lookup_module_env($action->{'source'},$action->{'name'},$rule_env);
	} else {
		$defaction = Kynetx::Environments::lookup_rule_env($action->{'name'},$rule_env);
	}
	
	if (defined $defaction && Kynetx::Expressions::is_defaction($defaction) ) {
		my $source = $action->{'source'} || "";
		my $name = $action->{'name'};
		my $required = $defaction->{'val'}->{'vars'} || [];
		$logger->debug("Found action ($name) in module [$source]");		
		$logger->debug("Module requires: [", join(",",@$required),"]");
		my $modifiers = {};
		return build_composed_action($source, 
			$name, 
			$rule_env,
			$defaction->{'val'},
			$req_info,
			$dd,
			$session,
			$arg_exp_vals,
			$action->{'modifiers'},
			$rule_name,
			$cb_func_name);
	}
	
	if ($action_name eq 'send_javascript') {
		my $js_blob =$arg_exp_vals->[0];
		$logger->trace("inject javascript: <| $js_blob |>");
		$js .=  $js_blob . ";\n";
		$js .= "$cb_func_name();\n";
		push( @{ $req_info->{'actions'} }, 'send_javascript' );
		push( @{ $req_info->{'tags'} },    '' );
		push( @{ $req_info->{'labels'} },  $action_expr->{'label'} );
		
	}

	my $config = {
		"txn_id"    => $req_info->{'txn_id'},
		"rule_name" => $rule_name,
		"rid"       => get_rid($req_info->{'rid'})
	};


	my $js_config = [];

	foreach my $k ( keys %{$config} ) {

		push @{$js_config},
		  Kynetx::JavaScript::gen_js_hash_item( $k,
			Kynetx::Expressions::typed_value( $config->{$k} ) );
	}

	# set default modifications
	my $mods = {
		delay      => 0,
		effect     => 'appear',
		scrollable => 0,
		draggable  => 0,
	};

	foreach my $m ( @{ $action->{'modifiers'} } ) {
		my $dobj = 
			Kynetx::Expressions::eval_expr($m->{'value'}, $rule_env, $rule_name, $req_info, $session);

		if (defined $dobj) {			
			if ($dobj->{'type'} eq 'null') {
				next;
			}
		}
		my $v = Kynetx::JavaScript::gen_js_expr($m->{'value'});
		$logger->trace("Modifier val: ",sub {Dumper($v)});
		$logger->trace("Denoted val: ",sub {Dumper($dobj)});
		$mods->{ $m->{'name'} } =  $v;

		

		$config->{ $m->{'name'} } = Kynetx::Expressions::den_to_exp($dobj);
#			Kynetx::Expressions::eval_expr(
#				$m->{'value'}, $rule_env, $rule_name, $req_info, $session
#			)
#		);

		# don't eval for sending to client.
		push @{$js_config},
		  Kynetx::JavaScript::gen_js_hash_item( $m->{'name'}, $m->{'value'} );
	}

	#    $logger->debug("JS config ", sub { Dumper $js_config});
	#    $logger->debug("Perl config ", sub { Dumper $config});

	# add to front of arg str (in reverse)
	#   this creates a JS string from the JS config
	unshift @{$args}, '{' . join( ",", @{$js_config} ) . '}';
	unshift @{$args}, $cb_func_name;
	unshift @{$args}, Kynetx::JavaScript::mk_js_str($uniq);

	# create comma separated list of arguments
	my $arg_str = join( ',', @{$args} ) || '';

	my $actions = {};

	# External resources need by action.
	my $resources;
		
	# Load actions from built in modules
	if ( defined $action->{'source'} ) {
		if ( $action->{'source'} eq 'twitter' ) {
			$actions = Kynetx::Modules::Twitter::get_actions();
		}
		elsif ( $action->{'source'} eq 'kpds' ) {
			$actions = Kynetx::Predicates::KPDS::get_actions();
		}
		elsif ( $action->{'source'} eq 'amazon' ) {
			$actions = Kynetx::Predicates::Amazon::get_actions();
		}
		elsif ( $action->{'source'} eq 'google' ) {
			$actions = Kynetx::Predicates::Google::get_actions();
		}
		elsif ( $action->{'source'} eq 'facebook' ) {
			$actions = Kynetx::Predicates::Facebook::get_actions();
		}
		elsif ( $action->{'source'} eq 'snow' ) {
			$actions   = Kynetx::Actions::LetItSnow::get_actions();
			$resources = Kynetx::Actions::LetItSnow::get_resources();
		}
		elsif ( $action->{'source'} eq 'jquery_ui' ) {
			$actions   = Kynetx::Actions::JQueryUI::get_actions();
			$resources = Kynetx::Actions::JQueryUI::get_resources();
		}
		elsif ( $action->{'source'} eq 'annotate' ) {
			$actions   = Kynetx::Actions::Annotate::get_actions();
			$resources = Kynetx::Actions::Annotate::get_resources();
		}
		elsif ( $action->{'source'} eq 'flippy_loo' ) {
			$actions   = Kynetx::Actions::FlippyLoo::get_actions();
			$resources = Kynetx::Actions::FlippyLoo::get_resources();
		}
		elsif ( $action->{'source'} eq 'email' ) {
			$actions   = Kynetx::Actions::Email::get_actions();
			$resources = Kynetx::Actions::Email::get_resources();
		}
		elsif ( $action->{'source'} eq 'odata' ) {
			$actions = Kynetx::Predicates::OData::get_actions();
		}
		elsif ( $action->{'source'} eq 'http' ) {
			$actions = Kynetx::Modules::HTTP::get_actions();
		}
		elsif ( $action->{'source'} eq 'twilio' ) {
			$actions = Kynetx::Modules::Twilio::get_actions();
		}
		elsif ( $action->{'source'} eq 'oauthmodule' ) {
			$actions = Kynetx::Modules::OAuthModule::get_actions();
		}
	}
	else {
		$actions = $default_actions;
	}

	my ( $action_js, $before, $after, $directive );
	if ( ref $actions->{$action_name} eq 'HASH' ) {
		$action_js = $actions->{$action_name}->{'js'};
		$before    = $actions->{$action_name}->{'before'} || \&noop;
		$after     = $actions->{$action_name}->{'after'} || [];
		$directive = $actions->{$action_name}->{'directive'} || \&noop;
	}
	else {
		$action_js = $actions->{$action_name};
		$before    = \&noop;
		$after     = [];
		$directive = \&noop;
	}

	# I really hate this but in order to make it this is what must
	# be done. Once impact is done we can remove this at some point.
	if ( $action_name eq "flippyloo" ) {
		$resources = Kynetx::Actions::FlippyLoo::get_resources();
	}

	$js .=
	  &$before( $req_info, $rule_env, $session, $config, $mods, $arg_exp_vals,
		$action->{'vars'} );
	$logger->debug( "Action $action_name (before) returns js: ", $js ) if $js;

#	$logger->debug("Action JS: $action_js");

	# the $action_js needs to be 'NO_JS' to avoid creating JS action
	if (defined $action_js 
          && ($action_js ne 'NO_JS')
	   ) {
	    # apply the action function
	    $js .= "(" . $action_js . "(" . $arg_str . "));\n";
	    
	    $logger->debug( "[action] ", $action_name, ' executing with args (',
			$arg_str, ')' );

	    push( @{ $req_info->{'actions'} }, $action_name );

	    # the after functions processes the JS as a chain and replaces it.
	    foreach my $a ( @{$after} ) {
	      $js = $a->(
			 $js, $req_info, $rule_env, $session, $config, $mods,
			 $action->{'vars'}
			);
	    }

	    push( @{ $req_info->{'tags'} }, ( $mods->{'tags'} || '' ) );
	    push( @{ $req_info->{'labels'} }, $action_expr->{'label'} || '' );
	}

	if ( $directive eq \&noop 
	  && ! defined $action_js
	   ) {
	  Kynetx::Errors::raise_error($req_info, 'warn',
				      "[action] $action_name undefined",
				      {'rule_name' => $rule_name,
				       'genus' => 'action',
				       'species' => 'undefined'
				      }
				     );

	}

	# now run directive functions to store those
	$directive->($req_info, $dd, $config, $arg_exp_vals );

	Kynetx::JavaScript::AST::register_resources( $req_info, $resources );

	return $js;
}

# some actions are overloaded depending on the args.  This function chooses
# the right JS function and adjusts the arg string.
sub choose_action {
	my ( $req_info, $dd, $action_name, $arg_den_vals, $rule_env, $rule_name, $args ) = @_;
	my $logger = get_logger();

	my $action_suffix = "_url";

	if ( $action_name eq 'float' || $action_name eq 'replace' ) {

		my $last_arg = pop @$arg_den_vals;

		my $url = gen_js_expr($last_arg);
		$url =~ s/'([^']*)'/$1/;

		$logger->debug( "URL: ", $url );

		my $pool = $req_info->{'pool'} ||= APR::Pool->new;

		my $parsed_url = APR::URI->parse( $req_info->{'pool'}, $url );
		my $parsed_caller =
		  APR::URI->parse( $req_info->{'pool'}, $req_info->{'caller'} );

		# URL not relative and not equal to caller
		if (
			$parsed_url->hostname
			&& (   $parsed_url->hostname ne $parsed_caller->hostname
				|| $parsed_url->port   ne $parsed_caller->port
				|| $parsed_url->scheme ne $parsed_caller->scheme )
		  )
		{

			$logger->debug(
				"[action] URL domain is ", $parsed_url->hostname,
				" & caller domain is ",    $parsed_caller->hostname
			);

			$action_suffix = "_html";

			# We need to eval the argument since it might be an expression
			$url =
			  den_to_exp(
				eval_expr( $last_arg, $rule_env, $rule_name, $req_info ) );

			#	    $url =~ s/^'(.*)'$/$1/;
			$logger->debug( "Fetching ", $url );

			# FIXME: should be caching this...
			my $content = LWP::Simple::get($url)
			  || "<!-- URL $url returned no content -->";
			$content =~ y/\n\r/  /;    # remove newlines
			$last_arg = Kynetx::Parser::mk_expr_node( 'str', $content );

			#$logger->debug("Last arg: ", sub { Dumper($last_arg) });

		}

		push @{$arg_den_vals}, $last_arg;
		$action_name = $action_name . $action_suffix;
	} elsif ( $action_name eq 'notify' ) {
		if ( scalar @{$arg_den_vals} == 2 ) {
			$action_name = 'notify_two';
		}
		else {
			$action_name = 'notify_six';
		}
	} elsif ( $action_name eq 'annotate_search_results' ||
		  $action_name eq 'annotate_local_search_results' 
		) {

	  # these two actions rely on the argument NOT getting eval'd because it 
	  # has to be a JavaScript var when the JS is generated to take advantage
	  # of the emitted JS. This functionality is deprecated

	  if (scalar @{$arg_den_vals} > 0) {
		my $last_den_arg = pop @$arg_den_vals;
		my $last_arg = pop @$args;

		$logger->debug("Replaced ", sub{Dumper $last_den_arg}, " with ", sub{Dumper $last_arg});
	  
		push @{$arg_den_vals}, $last_arg;
	  }

	}

	#    $logger->debug("[action] $action_name with ",
	#		   sub { join(", ", Dumper(@{$args}))});

	return ( $action_name, $arg_den_vals );
}

# after function for floats
sub handle_effects {
	my ( $js, $req_info, $rule_env, $session, $config, $mods ) = @_;

	my $logger = get_logger();

	my $uniq_id = $req_info->{'uniq_id'};

	$logger->debug( "[handle_effects] ", $mods->{'effect'} );

	my $effect_name;
  case: for ( $mods->{'effect'} ) {
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

	$logger->debug("Using effect $effect_name for $mods->{'effect'}");
	$js .= "\$K('#$uniq_id').$effect_name();";

	if ( $mods->{'draggable'} eq 'true' ) {
		$js .= "\$K('#$uniq_id').draggable();";
	}

	if ( $mods->{'scrollable'} eq 'true' ) {

		# do nothing
		#	    $js .= "new FixedElement('". $uniq_id . "');";
	}

	# FIXME: this isn't finished and doesn't work
	if ( $mods->{'highlight'} ) {
		my $color = '#ffff99';
	  case: for ( $mods->{'highlight'} ) {
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
				$color = $mods->{'highlight'};
			  }
		}

   #	    $js .= "new Effect.Highlight('$uniq_id', {startcolor: '$color', });"  ;
	}

	return $js;

}

sub handle_delay {
	my ( $js, $req_info, $rule_env, $session, $config, $mods ) = @_;

	if ( defined $mods && $mods->{'delay'} ) {
		my $rule_name = $config->{'rule_name'};
		my $delay_cb =
		    ";KOBJ.logger('timer_expired', '"
		  . $req_info->{'txn_id'} . "',"
		  . "'none', '', 'success', '"
		  . $rule_name . "','"
		  . get_rid($req_info->{'rid'}) . "');";

		$js .= $delay_cb;    # add in automatic log of delay expiration

		$js = "setTimeout(function() { $js },  ($mods->{'delay'} * 1000) ); \n";
	}

	return $js;

}

sub handle_popup {
	my ( $js, $req_info, $rule_env, $session, $config, $mods ) = @_;

	my $uniq_id = $req_info->{'uniq_id'};

	if ( $mods->{'effect'} eq "'onpageexit'" ) {
		my $funcname = "leave_" . $uniq_id;
		$js = "function $funcname () { " . $js . "};\n";
		$js .= "document.body.setAttribute('onUnload', '$funcname()');";
	}
	return $js;
}

sub get_precondition_test {
	my $rule = shift;

	$rule->{'pagetype'}->{'event_expr'}->{'pattern'}
	  || $rule->{'pagetype'}->{'pattern'};
}

sub get_precondition_vars {
	my $rule = shift;

	$rule->{'pagetype'}->{'event_expr'}->{'vars'}
	  || $rule->{'pagetype'}->{'vars'};
}

sub noop { return '' }

1;
