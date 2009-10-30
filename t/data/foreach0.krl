// adding a foreach to a select
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*)/" setting(name)
          foreach [0,1,2] setting(x)

          pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	  }     
          if (nighttime() && outside_state("UT"))
          then 
           float("absolute", "top: 10px", "right: 10px",
                 "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc + x)
             with delay = 0 and
                  draggable = true and
                  scrollable = true and
                  effect = "appear";


    }
}
