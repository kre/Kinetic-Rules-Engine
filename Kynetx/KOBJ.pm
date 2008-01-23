package Kynetx::KOBJ;
# file: Kynetx/KOBJ.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use constant DEFAULT_ACTION_HOST => '127.0.0.1';
use constant DEFAULT_JS_ROOT => $ENV{'KOBJ_ROOT'}.'/etc/js';
use constant DEFAULT_JS_VERSION => '0.8';

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


    my $js = "";
    if($file eq 'kobj.js') {

	$logger->info("Generating KOBJ file ", $file);

	my $action_host = $r->dir_config('action_host') || DEFAULT_ACTION_HOST;
	$js = get_kobj('http://', $action_host, $site, $js_version);


    } else {
	$logger->info("Outputting JS file ", $file);
	
	my $js_root = $r->dir_config('kobj_js_root') || DEFAULT_JS_ROOT;

	my $filename = join('/',($js_root,$js_version,$file));

	$logger->info("Outputting JS file ", $file, " from ", $filename);

	open(JS, "< $filename") || 
	    $logger->error("Can't open file $filename: $!\n");
	local $/ = undef;
	$js = <JS>;
	close JS;
	

    }

    print $js;
    return Apache2::Const::OK; 

}


1;




sub get_kobj {

    my ($proto, $host, $site_id, $js_version) = @_;

    # be sure to escape any $ that you want passed in the JS
    return <<EOF;

var KOBJ={
    version: '$js_version'
}

KOBJ.logger = function(msg,url,sense,rule) {

    e=document.createElement("script");
    e.src=KOBJ.url+"/log?msg="+msg+"&ts="+KOBJ.d+"&sense="+sense+"&url="+url+"&rule="+rule;
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
		    function() {KOBJ.logger("Someone clicked on " + name, 
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

KOBJ.d = (new Date).getTime();
KOBJ.proto = \'$proto\'; 
KOBJ.host_with_port = \'$host\'; 
KOBJ.site_id = $site_id;
KOBJ.url = KOBJ.proto+KOBJ.host_with_port+"/kobj/" + KOBJ.site_id;


r=document.createElement("script");
r.src=KOBJ.url + "/" + KOBJ.d + ".js";
r.src=r.src+"?";
r.src=r.src+"referer="+encodeURI(document.referrer) + "&";
r.src=r.src+"title="+encodeURI(document.title);
body=document.getElementsByTagName("body")[0];
body.appendChild(r);

EOF

}

