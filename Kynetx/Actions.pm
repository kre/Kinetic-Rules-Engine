package Kynetx::Actions;
# file: Kynetx/Actions.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
# 
use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Expressions qw(:all);
use Kynetx::Rules;
use Kynetx::Environments qw(:all);
use Kynetx::Session q/:all/;
use Kynetx::Log q/:all/;
use Kynetx::Json q/:all/;
use Kynetx::Actions::LetItSnow;
use Kynetx::Actions::JQueryUI;
use Kynetx::Actions::FlippyLoo;

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
eval_persistent_expr
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my($active,$test,$inactive) = (0,1,2);

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
      'after' => [\&handle_delay]
    },

    redirect => {
       'js' => <<EOF,
function(uniq, cb, config, url) {
    window.location = url;
    cb();
}
EOF
      'after' => [\&handle_delay]
    },

    # cb in load
    float_url => {
      'js' => <<EOF,
function(uniq, cb, config, pos, top, side, src_url) {
    var d = KOBJ.buildDiv(uniq, pos, top, side);
    \$K(d).load(src_url, cb);
    \$K('body').append(d);
}
EOF
     'after' => [\&handle_effects, \&handle_delay]
   },


    float_html => {
      'js' => <<EOF,
function(uniq, cb, config, pos, top, side, text) {
    var d = KOBJ.buildDiv(uniq, pos, top, side);
    \$K(d).html(text);
    \$K('body').append(d);
    cb();
}
EOF
     'after' => [\&handle_effects, \&handle_delay]
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
       'after' => [\&handle_delay]
    },

    notify_two => {
	 'js' => <<EOF,
function(uniq, cb, config, header, msg) {
  \$K.kGrowl.defaults.header = header;
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(msg);
  cb();
}
EOF
       'after' => [\&handle_delay]
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
      'after' => [\&handle_delay]
    },


    annotate_local_search_results => {
      'js' => <<EOF,
function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_local_search_results(annotate_fn, config, cb);
}
EOF
      'after' => [\&handle_delay]
    },

    percolate => {
        'js' => <<EOF,
function(uniq,cb,config,sel) {
    KOBJ.percolate(sel,config);
}
EOF
    'after' => [\&handle_delay]
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
      'after' => [\&handle_popup,\&handle_delay]
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
      'after' => [\&handle_delay]
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
        'after' => [\&handle_delay]
    },

    # need new "effects" model
    replace_inner => {
       'js' => <<EOF,
function(uniq, cb, config, sel, text) {
 \$K(sel).html(text);
 cb();
}
EOF
      'after' => [\&handle_delay]
    },


    move_after => {
      'js' => <<EOF,
function(uniq, cb, config, anchor, item) {
    var i = item;
    \$K(anchor).after(\$K(i));
    cb();
}
EOF
     'after' => [\&handle_delay]
    },

    move_to_top => {
       'js' => <<EOF,
function(uniq, cb, config, li) {
    \$K(li).siblings(':first').before(\$K(li));
    cb();
}
EOF
      'after' => [\&handle_delay]
    },


    replace_image_src => {
       'js' => <<EOF,
function(uniq, cb, config, id, new_url) {
    \$K(id).attr('src',new_url);
    cb();
}
EOF
      'after' => [\&handle_delay]
    },

    noop =>  {
       'js' => <<EOF,
function(uniq, cb, config) {
    cb();
}
EOF
      'after' => [\&handle_delay],
   },

    before => {
      'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).before(content);
    cb();
}
EOF
      'after' => [\&handle_delay]
    },

    after => {
       'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).after(content);
    cb();
}
EOF
      'after' => [\&handle_delay]
    },

    append => {
       'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).append(content);
    cb();
}
EOF
      'after' => [\&handle_delay]
    },
    prepend => {
       'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    \$K(sel).prepend(content);
    cb();
}
EOF
      'after' => [\&handle_delay]
    },

    sidetab => {
      'js' => <<EOF,
function(uniq, cb, config) {
    KOBJ.tabManager.addNew(config);
    cb();
}
EOF
     'after' => [\&handle_delay]
   },

    status_bar => {
      'js' => <<EOF,
function(uniq, cb, config, content) {
    KOBJ.statusbar(config, content);
    cb();
}
EOF
      'after' => [\&handle_delay]
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


};




# sub emit_var_decl {
#     my($scope_hash) = @_;
#     my $logger = get_logger();
#     my $js = '';
#     my $exempted = {
# 	'uniq' => 1,
# 	'uniq_id' => 1,
# 	'___order' => 1,
#     };
# #    $logger->debug(Dumper($scope_hash));
#     foreach my $lhs (@{$scope_hash->{'___order'}}) {
# 	next if $exempted->{$lhs} || $lhs =~ m/^datasource:/;
# 	my $val = $scope_hash->{$lhs};
# 	my $t = infer_type($val);
# 	if($t eq 'str') {
# 	    $val = "'".escape_js_str($val)."'";
# 	    # relace tmpl vars with concats for JS
# 	    $val =~ y/\n\r/  /; # remove newlines
# 	    $val =~ s/#{([^}]*)}/'+$1+'/g;
# 	} elsif ($t eq 'hash' || $t eq 'array') {
# 	    $val = encode_json($val);
# 	}
# 	$logger->debug("[decl] $lhs has type: $t");
# 	$js .= gen_js_var($lhs, $val);
#     }
#     return $js;

# }


sub build_js_load {
    my ($rule, $req_info, $rule_env, $session) = @_;

    my $logger = get_logger();

    # rule id
    my $uniq = int(rand 999999999);
    my $uniq_id = 'kobj_'.$uniq; 


    $rule_env = extend_rule_env(['uniq_id', 'uniq'], [$uniq_id,$uniq], $rule_env);
    $req_info->{'uniq'} = $uniq; # just for testing

    my $js = "";

   
#    $logger->debug("Rule ENV: ", sub {my $f = Dumper($rule_env);$f =~ y/\n//d;return $f});

    $logger->debug("Rule name: ", $rule->{'name'});
    # now do decls in order
   # my $scope_hash = flatten_env($rule_env);
   # $js .= emit_var_decl($scope_hash);

    # emits
    $js .= $rule->{'emit'} . "\n" if(defined $rule->{'emit'});


    # callbacks
    my $cb = '';
    if($rule->{'callbacks'}) {
	foreach my $sense ('success','failure') {
	    $cb .= gen_js_callbacks($rule->{'callbacks'}->{$sense},
				    $req_info->{'txn_id'},
		                    $sense,
				    $rule->{'name'},
				    $req_info->{'rid'}
		                   );
	}
    }
    
    my $cb_func_name = 'callBacks';
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
					$cb_func_name,
					$rule->{'name'}
		    );
	    } elsif(defined $action_expr->{'emit'}) {
		$js .= $action_expr->{'emit'}. ";\n";
		$js .= "$cb_func_name();\n";
		push(@{ $req_info->{'actions'} }, 'emit');
		push(@{ $req_info->{'tags'} }, '');
		push(@{ $req_info->{'labels'} }, $action_expr->{'label'});

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
	$cb_func_name, $rule_name) = @_;

    my $logger = get_logger();

    
    my $uniq = lookup_rule_env('uniq',$rule_env);
    my $uniq_id = lookup_rule_env('uniq_id',$rule_env);

    my $js = '';

    my $action = $action_expr->{'action'};
    my $action_name = $action->{'name'};

    my $args = $action->{'args'};
    
    # parse the action args and make the raw format available to the 'before' action
    my $before_args = Kynetx::Expressions::eval_rands($args, $rule_env, $rule_name,$req_info, $session);
    # get the values
    for (@{ $before_args }) {
        $_ = den_to_exp($_);
    }

    # process overloaded functions and arg reconstruction
    ($action_name, $args) = 
	choose_action($req_info, $action_name, $args, $rule_env, $rule_name);

    # this happens after we've chosen the action since it modifies args
    $args = gen_js_rands( $args );

    my @config = ("txn_id: '".$req_info->{'txn_id'} . "'", "rule_name: '$rule_name'", "rid: '".$req_info->{'rid'}."'");


    my $config = {"txn_id" => $req_info->{'txn_id'}, 
		  "rule_name" => $rule_name, 
		  "rid" => $req_info->{'rid'}};
    
   # set default modifications
    my $mods = {
	delay => 0,
	effect => 'appear',
	scrollable => 0,
	draggable => 0,
	};

    foreach my $m ( @{ $action->{'modifiers'} } ) {
	$mods->{$m->{'name'}} = gen_js_expr($m->{'value'});

#	$logger->debug(sub {Dumper($m)} );

	# Should the name be in quotes??

	$config->{$m->{'name'}} = 
 	               den_to_exp(eval_expr($m->{'value'}, 
						$rule_env, 
						$rule_name, 
						$req_info, 
						$session));
    }


    # add to front of arg str (in reverse)
    unshift @{ $args }, astToJson($config);
    unshift @{ $args }, $cb_func_name;
    unshift @{ $args }, mk_js_str($uniq);

    # create comma separated list of arguments 
    my $arg_str = join(',', @{ $args }) || '';

    my $actions = {};
    # External resources need by action.
    my $resources;
    if (defined $action->{'source'}) {
      if ($action->{'source'} eq 'twitter') {
	   $actions = Kynetx::Predicates::Twitter::get_actions();
      } elsif ($action->{'source'} eq 'kpds') {
	   $actions = Kynetx::Predicates::KPDS::get_actions();	
      } elsif ($action->{'source'} eq 'amazon') {
          $actions = Kynetx::Predicates::Amazon::get_actions();
      } elsif ($action->{'source'} eq 'google') {
          $actions = Kynetx::Predicates::Google::get_actions();
      } elsif ($action->{'source'} eq 'snow') {
          $actions = Kynetx::Actions::LetItSnow::get_actions();
          $resources = Kynetx::Actions::LetItSnow::get_resources(); 
      } elsif ($action->{'source'} eq 'jquery_ui') {
          $actions = Kynetx::Actions::JQueryUI::get_actions();
          $resources = Kynetx::Actions::JQueryUI::get_resources();
      } elsif ($action->{'source'} eq 'flippy_loo') {
          $actions = Kynetx::Actions::FlippyLoo::get_actions();
          $resources = Kynetx::Actions::FlippyLoo::get_resources();
      } elsif ($action->{'source'} eq 'odata') {
          $actions = Kynetx::Predicates::OData::get_actions();
      }
    } else {
      $actions = $default_actions;
    }

    my ($action_js, $before, $after);
    if (ref $actions->{$action_name} eq 'HASH') {
      $action_js = $actions->{$action_name}->{'js'};
      $before = $actions->{$action_name}->{'before'} || \&noop;
      $after = $actions->{$action_name}->{'after'} || [];
    } else {
      $action_js = $actions->{$action_name};
      $before = \&noop;
      $after = [];
    }
    # I really hate this but in order to make it this is what must
    # be done. Once impact is done we can remove this at some point.
    if($action_name eq "flippyloo") {
        $resources = Kynetx::Actions::FlippyLoo::get_resources();
    }

    $js .= &$before($req_info, $rule_env, $session, $config, $mods,$before_args);
    $logger->debug("Action $action_name (before) returns js: ",$js);
    if (defined $action_js) {
  
      # apply the action function
      $js .= "(". $action_js . "(" . $arg_str . "));\n";

      $logger->debug("[action] ", $action_name, 
		     ' executing with args (',$arg_str,')');


      push(@{ $req_info->{'actions'} }, $action_name);

      # the after functions processes the JS as a chain and replaces it.  
      foreach my $a (@{$after}) {
	 $js = $a->($js, $req_info, $rule_env, $session, $config, $mods);
      }
      

      push(@{ $req_info->{'tags'} }, ($mods->{'tags'} || ''));
      push(@{ $req_info->{'labels'} }, $action_expr->{'label'} || '');
    } else {
      $logger->warn("[action] ", $action_name, " undefined");
      
    }

    register_resources($req_info, $resources);

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


	    # We need to eval the argument since it might be an expression
	    $url = den_to_exp(
		    eval_expr($last_arg, $rule_env, $rule_name,$req_info));
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

# after function for floats
sub handle_effects {
 my ($js,$req_info,$rule_env,$session,$config,$mods)  = @_;

 my $logger=get_logger();

 my $uniq_id = lookup_rule_env('uniq_id',$rule_env);
 
 $logger->debug("[handle_effects] ", $mods->{'effect'});

 my $effect_name;
 case: for ($mods->{'effect'}) {
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
 $js .= "\$K('#$uniq_id').$effect_name();"  ;

 if ($mods->{'draggable'} eq 'true') {
   $js .= "\$K('#$uniq_id').draggable();";
 }
	
 if ($mods->{'scrollable'} eq 'true') {
   # do nothing 
   #	    $js .= "new FixedElement('". $uniq_id . "');";
 }

 # FIXME: this isn't finished and doesn't work
 if ($mods->{'highlight'}) {
   my $color = '#ffff99';
 case: for ($mods->{'highlight'}) {
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
 my ($js,$req_info,$rule_env,$session,$config,$mods)  = @_;

 if (defined $mods && $mods->{'delay'}) {
   my $rule_name = $config->{'rule_name'};
   my $delay_cb = 
     ";KOBJ.logger('timer_expired', '" .
       $req_info->{'txn_id'} . "'," .
	 "'none', '', 'success', '" .
	   $rule_name . "','".
	     $req_info->{'rid'} .
	       "');";

   $js .= $delay_cb;  # add in automatic log of delay expiration
	
   $js = "setTimeout(function() { $js },  ($mods->{'delay'} * 1000) ); \n";
 }

 return $js;

}

sub handle_popup {
  my ($js,$req_info,$rule_env,$session,$config,$mods)  = @_;

  my $uniq_id = lookup_rule_env('uniq_id',$rule_env);

  if ($mods->{'effect'} eq "'onpageexit'") {
    my $funcname = "leave_" . $uniq_id;
    $js = "function $funcname () { " . $js . "};\n";
    $js .= "document.body.setAttribute('onUnload', '$funcname()');"
  }
  return $js;
}

sub eval_post_expr {
    my($rule, $session, $req_info, $rule_env, $fired) = @_;
    
    my $js = '';

    my $logger = get_logger();
    $logger->debug("[post] evaling post expressions with rule ",
		   $fired ? "fired" : "notfired"
	);


    # set up post block execution
    my($cons,$alt);
    if (ref $rule->{'post'} eq 'HASH') { 
	my $type = $rule->{'post'}->{'type'};
	if($type eq 'fired') {
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'alt'};
	} elsif($type eq 'notfired') { # reverse sense
	    $cons = $rule->{'post'}->{'alt'};
	    $alt = $rule->{'post'}->{'cons'};
	} elsif($type eq 'always') { # cons is executed on both paths
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'cons'};
	}
    }

    # there's only persistent expressions
    if($fired) {
	$logger->debug("[post] evaling consequent");
	$js .= join(" ", 
		    map {eval_post_statement($_, $session, $req_info, $rule_env, $rule->{'name'})} @{ $cons });
    } else {
	$logger->debug("[post] evaling alternate");
	$js .= join(" ", 
		    map {eval_post_statement($_, $session, $req_info, $rule_env, $rule->{'name'})} @{ $alt } );
    }


}

sub eval_post_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $logger = get_logger();

    #default to true if not present
    my $test = 1;
    if (defined $expr->{'test'}) {
      $test = den_to_exp(
	Kynetx::Expressions::eval_expr($expr->{'test'}, 
						  $rule_env, 
						  $rule_name,
						  $req_info, 
						  $session
				      ));

      $logger->debug("[post] Evaluating statement test", $test);
    }


    if ($expr->{'type'} eq 'persistent' && $test) {
      return eval_persistent_expr($expr, $session, $req_info, $rule_env, $rule_name);
    } elsif ($expr->{'type'} eq 'log' && $test) {
      return eval_log_statement($expr, $session, $req_info, $rule_env, $rule_name);
    } elsif ($expr->{'type'} eq 'control' && $test) {
      return eval_control_statement($expr, $session, $req_info, $rule_env, $rule_name);
    } else {
      return '';
    }

  }

sub eval_persistent_expr {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $logger = get_logger();
#    $logger->debug("[post] ", $expr->{'type'});

    my $js = '';

    if ($expr->{'action'} eq 'clear') {
	if($expr->{'domain'} eq 'ent') {
	    session_clear($req_info->{'rid'}, $session, $expr->{'name'});
	}
    } elsif ($expr->{'action'} eq 'set') {
	if($expr->{'domain'} eq 'ent') {
	    session_set($req_info->{'rid'}, $session, $expr->{'name'});
	}
    } elsif ($expr->{'action'} eq 'iterator') {
#	$logger->debug(Dumper($session));
	my $by = 
	    den_to_exp(
		eval_expr($expr->{'value'},
			     $rule_env,
			     $rule_name,
			     $req_info,
			     $session));
	$by = -$by if($expr->{'op'} eq '-=');
	my $from = 
	    den_to_exp(
		eval_expr($expr->{'from'},
			     $rule_env,
			     $rule_name,
			     $req_info,
			     $session));
	if($expr->{'domain'} eq 'ent') {
	    session_inc_by_from($req_info->{'rid'},
				$session,
				$expr->{'name'},
				$by,
				$from
		);
	}
#	$logger->debug(Dumper($session));
    } elsif ($expr->{'action'} eq 'forget') {
	if($expr->{'domain'} eq 'ent') {
	    session_forget($req_info->{'rid'},
			   $session,
			   $expr->{'name'},
			   $expr->{'regexp'});
	}
    } elsif ($expr->{'action'} eq 'mark') {
	if($expr->{'domain'} eq 'ent') {
	    my $url = defined $expr->{'with'} ?
		den_to_exp(
		    eval_expr($expr->{'with'},
				 $rule_env,
				 $rule_name,
				 $req_info,
				 $session)) 
		: $req_info->{'caller'};
#	    $logger->debug("Marking trail $expr->{'name'} with $url");
	    session_push($req_info->{'rid'},
			 $session,
			 $expr->{'name'},
			 $url
			 );
	}
    }

    return $js;
}


sub eval_log_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

#    my $logger = get_logger();

#    $logger->debug("eval_log_statement ", Dumper($expr));

    my $js ='';

    # call the callback server here with a HTTP GET
    $js = explicit_callback($req_info, 
			    $rule_name, 
			    den_to_exp(
				       eval_expr($expr->{'what'},
						    $rule_env,
						    $rule_name,
						    $req_info,
						    $session)));

    return $js;
}


sub eval_control_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $js ='';

    if ($expr->{'statement'} eq 'last') {
      $req_info->{$req_info->{'rid'}.':last'} = 1;
    }

    return $js;
}


#
# This will put out the needed code that action use to express
# that they have external js or css.  If no resources are need
# it just return ""
#
sub mk_registered_resource_js {
   my($req_info) = @_;

   # For each resource lets make a register resources call.
   my $register_resources_js = '';

   my $logger = get_logger();


#   $logger->debug("Req info for register resources ", sub {Dumper $req_info});
   
   if($req_info->{'resources'}
     ) {

     my $register_resources_json = Kynetx::Json::encode_json($req_info->{'resources'});
     $register_resources_js = "KOBJ.registerExternalResources('" .
       $req_info->{'rid'} .
	 "', " .
	   $register_resources_json .
	     ");";

   }
   return $register_resources_js;
}

sub register_resources {
   my($req_info, $resources) = @_;
   # Add the needed resources
   # These are the urls of either js or css that need to be added because an 
   # action needs them before they execute
   if($resources) {
     push(@{ $req_info->{'resources'} }, $resources);
   }

}



sub get_precondition_test {
    my $rule = shift;

    $rule->{'pagetype'}->{'event_expr'}->{'pattern'} || $rule->{'pagetype'}->{'pattern'} ;
}

sub get_precondition_vars {
    my $rule = shift;

    $rule->{'pagetype'}->{'event_expr'}->{'vars'} || $rule->{'pagetype'}->{'vars'};
}

sub noop {return ''};

1;
