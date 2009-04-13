// global with cachable datasource
ruleset 10 {

    global {
        emit <<
var pagename = 'foobar';
>>;

	datasource foozle <- "http://www.windley.com/rss.xml" cachable;

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
