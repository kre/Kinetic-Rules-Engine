// adding selection variables
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*)/" setting(name)
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}     
        if (time:nighttime() && location:outside_state("UT"))
        then 
	alert("hello");

    }
}
