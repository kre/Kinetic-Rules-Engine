// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      key googleanalytics "kfjsklfjslkfjslkfs"
      key twitter {
        "consumer_key": 583758935739,
        "consumer_secret" : "3HNb7NfksjflskIm2BuxKPSg6JYvMtLahvkMt6Std5SO0"
      }

    }

    rule test0 is active {
        select using "/test/" setting()

	alert("hello");

    }
}
