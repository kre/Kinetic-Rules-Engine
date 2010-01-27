// adding a foreach to a select
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*)/" setting(name)
          foreach [0,1,2] setting(x)
            foreach ["a","b","c"] setting(y)

          pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	  }     
          if (nighttime() && outside_state("UT"))
          then 
	        alert("hello");

    }
}
