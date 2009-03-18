package Kynetx::KOBJ;
# file: Kynetx/KOBJ.pm

use strict;
use warnings;

use File::Find::Rule;
use Log::Log4perl qw(get_logger :levels);

use constant DEFAULT_SERVER_ROOT => 'kobj.net';
use constant DEFAULT_ACTION_PREFIX => 'kobj-cs';
use constant DEFAULT_LOG_PREFIX => 'kobj-log';
use constant DEFAULT_ACTION_HOST => '127.0.0.1';
use constant DEFAULT_LOG_HOST => '127.0.0.1';
use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
use constant DEFAULT_JS_VERSION => '0.9';

use Kynetx::Util qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Datasets qw(:all);
use Kynetx::Rules qw(:all);
#use Kynetx::Memcached qw(:all);


sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);
    my $logger = get_logger();

    $r->content_type('text/javascript');

#    return Apache2::Const::DECLINED 
#	unless $r->content_type() eq 'text/javascript';

    my ($rid,$file) = $r->uri =~ m#/js/([^/]+)/(.*\.js)#;

    Log::Log4perl::MDC->put('site', $rid);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    my $js_version = $r->dir_config('kobj_js_version') || DEFAULT_JS_VERSION;
    my $js_root = $r->dir_config('kobj_js_root') || DEFAULT_JS_ROOT;


    my $js = "";
    if($file eq 'kobj.js') {

	$logger->info("Generating client initialization file ", $file);

	my $req_info = Kynetx::Request::build_request_env($r, 'initialize', $rid);

	Kynetx::Request::log_request_env($logger, $req_info);

	Log::Log4perl::MDC->put('rule', $req_info->{'txn_id'});  


	my($prefix, $middle, $root) = $r->hostname =~ m/^([^.]+)\.?(.*)\.([^.]+\.[^.]+)$/;

	$logger->debug("Hostname: ", $prefix, " and ", $root);

	my $action_host;
	my $log_host;
	# track virtual hosts
	if($root eq DEFAULT_SERVER_ROOT ||
	   $r->hostname =~ m/\d+\.\d+\.\d+\.\d+/) {
	    $action_host = $r->dir_config('action_host') || DEFAULT_ACTION_HOST;
	    $log_host = $r->dir_config('log_host') || DEFAULT_LOG_HOST;
	} else {
	    $middle .= "." if $middle;
	    my $ending = "." . $middle  . $root;
	    $action_host = DEFAULT_ACTION_PREFIX . $ending;
	    $log_host = DEFAULT_LOG_PREFIX . $ending;
	}

	$logger->info("Generating KOBJ file ", $file, ' with action host ' , $action_host);


	$js = get_kobj($r,'http://', $action_host, $log_host, $rid, $js_version, $req_info);


    } elsif($file eq 'kobj-static.js') {

	if($r->dir_config('UseCloudFront') && 
            ($rid eq 'static' || 
	     $rid eq 'shared' || 
	     $rid eq '996337974') # Backcountry
	    ) { # redirect to CloudFront
	    # FIXME: if config directive not available, log error
	    my $version = 
		$r->dir_config('CloudFrontFile') || 'kobj-static-1.js';
	    my $cf_url = "http://static.kobj.net/". $version;
	    $logger->info("Redirecting to Cloudfront ", $cf_url);
	    $r->headers_out->set(Location => $cf_url);
	    
	    return Apache2::Const::REDIRECT;
	    
	} else {  # send the file from here
	    $logger->info("Generating KOBJ static file ", $file);
	    $js = get_js_file($file,$js_version,$js_root);
	}
	
    } elsif($r->path_info =~ m!/version/! ) {
	show_build_num($r);
    } else {

	$js = get_js_file($file,$js_version,$js_root);

    }

    print $js;

    return Apache2::Const::OK; 

}


sub get_js_file {
    my ($file, $js_version, $js_root) = @_;

    my $logger = get_logger();
    my $filename = join('/',($js_root,$js_version,$file));

    $logger->debug("Outputting JS file ", $file, " from ", $filename);

    open(JS, "< $filename") || 
	$logger->error("Can't open file $filename: $!\n");
    local $/ = undef;
    my $js = <JS>;

    close JS;
    
    return $js;

}


sub get_datasets {
    my ($svn_conn, $req_info) = @_;

    my $rid = $req_info->{'rid'};

    my $logger = get_logger();
    $logger->debug("Getting ruleset for $rid");

    my $js = "";

    my $ruleset = Kynetx::Rules::get_rules_from_repository($rid, $svn_conn, $req_info);

    if( $ruleset->{'global'} ) {
	$logger->debug("Processing decls for $rid");
	foreach my $g (@{ $ruleset->{'global'} }) {

	    if(defined $g->{'name'} && Kynetx::Datasets::cache_dataset_for($g) >= 24*60*60) { # more than 24 hours
		$logger->debug("Creating JS for decl " . $g->{'name'});
		$js .= mk_dataset_js($g, $req_info, {}); # empty rule env
	    }
	}
    } 
    $logger->debug("Returning JS for global decls");
    return $js;

}


sub get_kobj {


    my ($r, $proto, $host, $log_host, $rid, $js_version, $req_info) = @_;

    my $data_root = "/web/data/client/$rid";

    my $logger = get_logger();

    $logger->debug("Initializing memcached");
#    Kynetx::Memcached->init();


    # be sure to escape any $ that you want passed in the JS
    # kobj.js preamble
    my $js = <<EOF;

var KOBJ={
    version: '$js_version'
}

KOBJ.search_annotation = {};
KOBJ.search_annotation.defaults = {
  "name": "KOBJ",
  "sep": "<div style='padding-top: 13px'>|</div>",
  "text_color":"#CCC",
  "height":"40px",
  "left_margin": "46px",
  "right_padding" : "15px",
  "font_size":"12px",
  "font_family": "Verdana, Geneva, sans-serif"
};

KOBJ.annotate_search_results = function(annotate) {

  function mk_list_item(i) {
    return \$K("<li class='KOBJ_item'>").css(
          {"float": "left",
	   "margin": "0",
	   "vertical-align": "middle",
	   "padding-left": "4px",
	   "color": KOBJ.search_annotation.defaults.text_color,
	   "white-space": "nowrap",
           "text-align": "center"
          }).append(i);
  }

  function mk_rm_div (anchor) {
    var logo_item = mk_list_item(anchor);
    var logo_list = \$K('<ul>').css(
          {"margin": "0",
           "padding": "0",
           "list-style": "none"
          }).attr("id", KOBJ.search_annotation.defaults.name+"_logo_list").append(logo_item);
    var inner_div = \$K('<div>').css(
          {"float": "left",
           "display": "inline",
           "height": KOBJ.search_annotation.defaults.height,
           "margin-left": KOBJ.search_annotation.defaults.left_margin,
           "padding-right": KOBJ.search_annotation.defaults.right_padding
          }).append(logo_list);
    if (KOBJ.search_annotation.defaults.tail_background_image){
      inner_div.css({
           "background-image": "url(" + KOBJ.search_annotation.defaults.tail_background_image + ")",
           "background-repeat": "no-repeat",
           "background-position": "right top"
      })
    }
    var rm_div = \$K('<div>').css(
          {"float": "right",
           "width": "auto",
           "height": KOBJ.search_annotation.defaults.height,
           "font-size": KOBJ.search_annotation.defaults.font_size,
           "line-height": "normal",
           "font-family": KOBJ.search_annotation.defaults.font_familty
	   }).append(inner_div);
    if (KOBJ.search_annotation.defaults.head_background_image){
     rm_div.css({
           "background-image": "url(" + KOBJ.search_annotation.defaults.head_background_image +")",
           "background-repeat": "no-repeat",
           "background-position": "left top"
      })
    }
    return rm_div;
  }

  \$K("li.g, li div.res").each(function() {
        var contents = annotate(this);
        if (contents) {
          if(\$K(this).find('#'+KOBJ.search_annotation.defaults.name+'_anno_list+ li').is('.'+KOBJ.search_annotation.defaults.name+'_item')) {
             \$K(this).find('#'+KOBJ.search_annotation.defaults.name+'_anno_list').append(mk_list_item(KOBJ.search_annotation.defaults.sep)).append(mk_list_item(contents));
          } else {
             \$K(this).find("div.s,div.abstr").prepend(mk_rm_div(contents));
          }
        }
   });

}

KOBJ.logger = function(type,txn_id,element,url,sense,rule) {
    e=document.createElement("script");
    e.src=KOBJ.logger_url+"?type="+type+"&txn_id="+txn_id+"&element="+element+"&ts="+KOBJ.d+"&sense="+sense+"&url="+escape(url)+"&rule="+rule;
    body=document.getElementsByTagName("body")[0];
    body.appendChild(e);
}

KOBJ.obs = function(type, txn_id, name, sense, rule) {
    if(type == 'class') {
	\$K('.'+name).click(function(e1) {
	    var tgt = \$K(this);
	    var b = tgt.attr('href') || '';
	    KOBJ.logger("click",
			txn_id,
			name, 
			b, 
			sense,
			rule
	    );
            if(b) { tgt.attr('href','#'); }  // # gets replaced by redirect
	    });
    } else {
	\$K('#'+name).click(function(e1) {
	    var tgt = \$K(this);
	    var b = tgt.attr('href') || '';
	    KOBJ.logger("click",
			txn_id,
			name, 
			b, 
			sense,
			rule
	    );
            if(b) { tgt.attr('href','#'); }  // # gets replaced by redirect
	    });
    }
}



KOBJ.fragment = function(base_url) {
    e=document.createElement("script");
    e.src=base_url;
    body=document.getElementsByTagName("body")[0];
    body.appendChild(e);
}

KOBJ.update_elements  = function (params) {
    for (var mykey in params) {
 	\$K("#kobj_"+mykey).html(params[mykey]);
    };
}

// wrap some effects for use in embedded HTML
KOBJ.Fade = function (id) {
    \$K(id).fadeOut()
}

KOBJ.BlindDown = function (id) {
    \$K(id).slideDown()
}

KOBJ.BlindUp = function (id) {
    \$K(id).slideUp()
}

KOBJ.BlindUp = function (id, speed) {
    \$K(id).slideUp(speed)
}

KOBJ.hide = function (id) {
    \$K(id).hide();
}

// helper functions
KOBJ.buildDiv = function (uniq, pos, top, side) {
    var vert = top.split(/\\s*:\\s*/);
    var horz = side.split(/\\s*:\\s*/);
    var div_style = {
        position: pos,
        zIndex: '9999',
        opacity: 0.999999,
        display: 'none'
    };
    div_style[vert[0]] = vert[1];
    div_style[horz[0]] = horz[1];
    var id_str = 'kobj_'+uniq;
    var div = document.createElement('div');
    return \$K(div).attr({'id': id_str}).css(div_style);
}

KOBJ.get_host = function(s) {
 return s.match(/^(?:\\w+:\\/\\/)?([\\w.]+)/)[1]; # .
}

KOBJ.pick = function(o) {
    if (o) {
        return o[Math.floor(Math.random()*o.length)];
    } else {
        return o;
    }
}


KOBJ.d = (new Date).getTime();
KOBJ.proto = \'$proto\'; 
KOBJ.host_with_port = \'$host\'; 
KOBJ.loghost_with_port = \'$log_host\'; 
KOBJ.site_id = \'$rid\';
KOBJ.url = KOBJ.proto+KOBJ.host_with_port+"/ruleset/eval/" + KOBJ.site_id;
KOBJ.logger_url = KOBJ.proto+KOBJ.loghost_with_port+"/log/" + KOBJ.site_id;


if(typeof(kvars) != "undefined") {
    KOBJ.kvars_json = \$K.toJSON(kvars);
} else {
    KOBJ.kvars_json = '';
}
EOF

    # add in datasets  The datasets param is a filter
    my @ds;

    my $datasets = $req_info->{'datasets'};
    
    if($datasets) {
	@ds = split(/,/, $datasets);
    } else {
	@ds = File::Find::Rule->file()
                              ->name( '*.pm' )
                              ->in( $data_root );
    }

    foreach my $dataset (@ds) {
	my $fn = "$data_root/$dataset.json";
	if(-e $fn) {
	    open(JSON, $fn ) || 
		$logger->error("Can't open file $data_root/$dataset.json: $!\n");
	    local $/ = undef;
	    $js .= "KOBJ.$dataset = ";
	    $js .= <JSON>;
	    $js .= ";\n";
	    close JS;
	}
    }

    # create param string for tacking on to CS request
    my $param_names = $req_info->{'param_names'};
    my $param_str = "";
    foreach my $n (@{ $param_names }) {
#	$logger->debug("Adding $n to parameters...");
	$param_str .= "&$n=".$req_info->{$n};
    }

#    $js .= get_datasets($r->dir_config('svn_conn'), $req_info);

    $logger->debug("Done with data set generation");


    $js .= <<EOF;
 

KOBJ.r=document.createElement("script");
KOBJ.r.src=
    KOBJ.url + "/" 
             + KOBJ.d 
	     + ".js"
             + "?"
             + "caller=" 
             + escape(document.URL) 
	     + "&referer=" 
             + escape(document.referrer) 
	     + "&kvars=" 
             + escape(KOBJ.kvars_json) 
	     + "&title=" 
             + encodeURI(document.title) 
             + "$param_str";



KOBJ.body=document.getElementsByTagName("body")[0];
\$K(document).ready(function() {
    KOBJ.body.appendChild(KOBJ.r);
});

EOF

}




1;


