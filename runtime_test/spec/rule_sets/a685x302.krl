ruleset a685x302 {

  meta {
    name "Annotate via event with no javascript"
    description <<
    >>
    author "Someone"
  }

 dispatch {
    domain "google.com"
    domain "bing.com"
    domain "yahoo.com"
  }

 global {}

 rule search_annotate_rule is active {
   select using "google.com|bing.com/search|search.yahoo.com/search"
          setting()
   every {
    annotate:annotate("rentals") with remote = "event";

  }
    }
  rule annotate_rentals is active {
    select when web annotate_search name "rentals" setting ()
      foreach annotate_data setting (akey,value)
      pre {
        annotate_instance = page:env("annotate_instance");
        annotate_data = page:env("annotatedata").as("json");
      }

    annotate:add_annotation(akey, "<span class="annotation">My Annotation</span>",    annotate_instance);

   }
}