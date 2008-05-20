package Kynetx::KOBJ;
# file: Kynetx/KOBJ.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use constant DEFAULT_ACTION_HOST => '127.0.0.1';
use constant DEFAULT_LOG_HOST => '127.0.0.1';
use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
use constant DEFAULT_JS_VERSION => '0.8';

my @js_files = qw(
prototype.js
effects.js
dragdrop.js
kobj-extras.js
);

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');

#    return Apache2::Const::DECLINED 
#	unless $r->content_type() eq 'text/javascript';

    my $logger = get_logger();

    my ($site,$file) = $r->uri =~ m#/js/(\d+)/(.*\.js)#;

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...


    my $js_version = $r->dir_config('kobj_js_version') || DEFAULT_JS_VERSION;
    my $js_root = $r->dir_config('kobj_js_root') || DEFAULT_JS_ROOT;


    my $js = "";
    if($file eq 'kobj.js') {

	$logger->info("Generating KOBJ file ", $file);
	my $action_host = $r->dir_config('action_host') || DEFAULT_ACTION_HOST;
	my $log_host = $r->dir_config('log_host') || DEFAULT_LOG_HOST;
	$js .= get_kobj('http://', $action_host, $log_host, $site, $js_version);


    } elsif($file eq 'kobj-static.js') {

	$logger->info("Generating KOBJ static file ", $file);
	foreach my $file (@js_files) {
	    $js .= get_js_file($file,$js_version,$js_root);
	}


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


    my ($proto, $host, $log_host, $site_id, $js_version) = @_;

    # be sure to escape any $ that you want passed in the JS
    return <<EOF;

var KOBJ={
    version: '$js_version'
}

KOBJ.logger = function(type,element,url,sense,rule) {

    e=document.createElement("script");
    e.src=KOBJ.logger_url+"?type="+type+"&element="+element+"&ts="+KOBJ.d+"&sense="+sense+"&url="+escape(url)+"&rule="+rule;
    body=document.getElementsByTagName("body")[0];
    body.appendChild(e);
}

KOBJ.obs_one = function(name,e, sense, rule) {
    if (e) {
      var b = e.readAttribute('href') ? 
	      e.readAttribute('href') : '';
      e.writeAttribute({href: '#'});
      Event.observe(e, 
	  	    "click", 
		    function() {KOBJ.logger("click",
					    name, 
					    b, 
					    sense,
					    rule
					   );
		                false;
			       }
		   );
    }
}
 
KOBJ.obs = function(type, name, sense, rule) {
    if(type == 'class') {
	\$\$('.'+name).each(  
	    function(e) {  
		KOBJ.obs_one(name, e, sense, rule);
	    }  
	);  
    } else {
	KOBJ.obs_one(name,\$(name), sense, rule);
    }
}


KOBJ.fragment = function(base_url) {
    e=document.createElement("script");
    e.src=base_url;
    body=document.getElementsByTagName("body")[0];
    body.appendChild(e);
}

KOBJ.update_elements  = function (params) {
    var params = \$H(params);
    
    params.each(function(pair) {
	\$("kobj_"+pair.key).update(pair.value);
    });
}


KOBJ.d = (new Date).getTime();
KOBJ.proto = \'$proto\'; 
KOBJ.host_with_port = \'$host\'; 
KOBJ.loghost_with_port = \'$log_host\'; 
KOBJ.site_id = $site_id;
KOBJ.url = KOBJ.proto+KOBJ.host_with_port+"/kobj/" + KOBJ.site_id;
KOBJ.logger_url = KOBJ.proto+KOBJ.loghost_with_port+"/log/" + KOBJ.site_id;


r=document.createElement("script");
r.src=KOBJ.url + "/" + KOBJ.d + ".js";
r.src=r.src+"?";
r.src=r.src+"referer="+escape(document.referrer) + "&";
r.src=r.src+"title="+encodeURI(document.title);
body=document.getElementsByTagName("body")[0];
body.appendChild(r);

EOF

}




1;


