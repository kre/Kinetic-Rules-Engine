// dispatch with some rules
ruleset 10 {

   dispatch {
      domain "www.windley.com" -> "966337974"
      domain "google.com" -> "966337974"
      domain "www.circuitcity.com" -> "966337982"

      domain "www.google.com"
      domain "search.yahoo.com"

   }

    rule testa is active {
        select using "/test/" setting()
        replace("test","test");
    }

    rule testb is active {
        select using "/test/" setting()
        replace("test","test");
    }


}
