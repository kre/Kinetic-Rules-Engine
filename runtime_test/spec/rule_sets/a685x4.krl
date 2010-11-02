ruleset a685x4 {
  meta {
    name "MultiAppTestTwo"
    description <<
      Test multiple apps on a single page
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
    // pre {   }
    notify("MultiAppTestTwo", "Muti Test 2 fired") with sticky = true;
  }
}