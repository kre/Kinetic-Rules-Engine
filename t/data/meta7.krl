// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      key googleanalytics "kfjsklfjslkfjslkfs"
      key twitter {
        "consumer_key": "jPlIPAk1g848tonC2yNA",
        "consumer_secret" : "3HNb7NfksjflskIm2BuxKPSg6JYvMtLahvkMt6Std5SO0"
      }

    }

    rule test0 is active {
        select using "/test/" setting()


        pre {
	}     

        float("absolute", "top: 10px", "right: 10px",
              "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc);

    }
}
