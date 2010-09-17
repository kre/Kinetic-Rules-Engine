// global with emit
ruleset 10 {

    global {

        emit <<
var pagename = 'foobar';
>>;

        emit <<
var pagename2 = 'fizzle';
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
