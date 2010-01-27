// select with var
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting(x)
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}     
	alert("hello");

    }
}
