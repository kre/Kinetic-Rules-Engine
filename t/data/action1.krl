// just one modifiers for action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}     
      float("absolute", "top: 10px", "right: 10px", "url")
        with delay = 0 ;

    }
}
