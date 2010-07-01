// adding a foreach to a select
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*)/" setting(name)
          foreach {"a": 1, "b": 2, "c":3} setting(k,v)

          pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	  }     
          if (nighttime() && outside_state("UT"))
          then 
            alert("hello") with a = {"a": 1, "b": 2};
		 

    }
}
