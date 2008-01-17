// adding second declaration to pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}     
        replace("test","test");
    }
}
