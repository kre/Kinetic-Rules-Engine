// global with extended quote and expression
ruleset 10 {

    global {
	datasource bamboozle <- "http://www.windley.com/rss.xml";

	dataset frizzle <- "http://www.windley.com/rss.xmljson" cachable;

	x = 5;
	current_price = stocks:last("^DJI");

        emit <<
var pagename = 'foobar';
>>;

	y = <<
<p>This is a test</p>
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
