// global with 2 datasource
ruleset 10 {

    global {
	datasource bamboozle <- "http://www.windley.com/rss.xml";

	dataset frizzle <- "http://www.windley.com/rss.xmljson" cachable;

	datasource foozle <- "http://www.windley.com/rss.xml" cachable for 3 hours;

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
      float("absolute", "top: 10px", "right: 10px",
            "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc)
        with delay = 0 ;

    }
}
