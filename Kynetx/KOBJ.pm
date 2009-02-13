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


sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    $r->content_type('text/javascript');

#    return Apache2::Const::DECLINED 
#	unless $r->content_type() eq 'text/javascript';

    my $logger = get_logger();

    my ($site,$file) = $r->uri =~ m#/js/([^/]+)/(.*\.js)#;

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...


    my $js_version = $r->dir_config('kobj_js_version') || DEFAULT_JS_VERSION;
    my $js_root = $r->dir_config('kobj_js_root') || DEFAULT_JS_ROOT;


    my $js = "";
    if($file eq 'kobj.js') {

	$logger->info("Generating KOBJ file ", $file);

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


	my $req = Apache2::Request->new($r);
	

	$js = get_kobj('http://', $action_host, $log_host, $site, $js_version, $req);


    } elsif($file eq 'kobj-static.js') {

	if($r->dir_config('UseCloudFront') && 
            ($site eq 'static' || 
	     $site eq 'shared' || 
	     $site eq '996337974') # Backcountry
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


sub get_kobj {


    my ($proto, $host, $log_host, $site_id, $js_version, $req) = @_;

    my $data_root = "/web/data/client/$site_id";

    my $logger = get_logger();

    # be sure to escape any $ that you want passed in the JS
    # kobj.js preamble
    my $js = <<EOF;

var KOBJ={
    version: '$js_version'
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
 return s.match(/^(?:\\w+:\\/\\/)?([\\w.]+)/)[1];
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
KOBJ.site_id = \'$site_id\';
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

    my $datasets = $req->param('datasets');
    
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
    my @param_names = $req->param;
    my $param_str = "";
    foreach my $n (@param_names) {
#	$logger->debug("Adding $n to parameters...");
	$param_str .= "&$n=".$req->param($n);
    }


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


