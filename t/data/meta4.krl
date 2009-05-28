// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
      Ruleset for testing something or other.
      >>
    }

    rule test0 is active {
        select using "/test/" setting()


        pre {
	}     

        float("absolute", "top: 10px", "right: 10px",
              "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc);

    }
}
