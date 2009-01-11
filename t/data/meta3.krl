// adding modifiers to action
ruleset 10 {

    meta {
    }

    rule test0 is active {
        select using "/test/" setting()


        pre { 
	}     

        float("absolute", "top: 10px", "right: 10px",
              "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc);

    }
}
