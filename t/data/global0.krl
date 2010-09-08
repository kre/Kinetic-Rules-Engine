// empty global
ruleset 10 {

    global {
        emit <<
var pagename = 'foobar';
>>;

    }

    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}
	alert("hello");

    }
}
