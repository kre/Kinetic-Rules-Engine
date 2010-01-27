// global with 2 datasource
ruleset 10 {

    global {
	datasource bamboozle <- "http://www.windley.com/rss.xml";

	dataset frizzle <- "http://www.windley.com/rss.xmljson" cachable;

	x = 5;

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
