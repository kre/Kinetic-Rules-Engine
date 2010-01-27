// css in global (two)
ruleset 10 {

    global {
        css <<a:link {color:black}>>;
        css <<a:link {color:black}>>;
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
