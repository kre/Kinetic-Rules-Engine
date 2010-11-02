ruleset a685x3 {
  meta {
    name "MultiAppTestOne"
    description <<
      Test case for multiple apps on one page fireing at a time.
    >>
    author ""
    // Uncomment this line to require Markeplace purchase to use this app.
    // authz require user
    logging off
  }

  dispatch {
    // Some example dispatch domains
    // domain "exmple.com"
    // domain "other.example.com"
  }

  global {

  }

  rule first_rule is active {
    select when pageview ".*" setting ()
    notify("MultiAppTestOne", "MultiAppTestOne Fired") with sticky = true;
  }
}