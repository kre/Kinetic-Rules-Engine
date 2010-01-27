// select without setting
ruleset 10 {
    rule test0 is active {
        select using "/test/" 
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}     
	alert("hello");
    }
}
