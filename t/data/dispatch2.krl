// dispatch without any rules
ruleset 10 {

   dispatch {

      domain "www.google.com"
      domain "search.yahoo.com"

      iframe "google.com/ads/\d+"

      domain "www.google.com" -> "966337974"
      domain "google.com" -> "966337974"
      domain "www.circuitcity.com" -> "966337982"

      iframe "yahoo.com/omni/\d+"


   }

}
