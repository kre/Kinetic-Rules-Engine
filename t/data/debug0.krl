// logging pragma in meta block
ruleset 10 {

    meta {
      description <<
      Ruleset for testing something or other.
      >>
      logging on
    }

    rule test0 is active {
        select using "/test/" setting()


        pre {
	}     

        float("absolute", "top: 10px", "right: 10px",
              "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc);

    }
}
