// Testing a problem Casey found
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
	pre {
	   city = geoip:city();
           state = geoip:state();
  	}	
    	if state("AL") && city("Denver")
   	then every {	 
        alert_label_1:
            alert("This is alert 1")
            with
                tags = ["alert", "label", "1"];
        alert_label_2:
            alert("Alert Message 2")
            with
                tags = ["alert", "label", "2"];
    	 }
    }
}
