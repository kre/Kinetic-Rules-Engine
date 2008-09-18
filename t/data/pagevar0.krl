// A simple page variable in pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    zip = page:var("zip");
	}     
        float("absolute", "top: 10px", "right: 10px",
                 "/cgi-bin/weather.cgi?zip=" + zip);

    }
}
