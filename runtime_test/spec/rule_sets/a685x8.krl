ruleset a685x8 {
  meta {
    name "SimpleDevRule"
    description <<

    >>
    author ""
    // Uncomment this line to require Marketplace purchase to use this app.
    // authz require user
    logging off
  }

  dispatch {
    // Some example dispatch domains
    // domain "example.com"
    // domain "other.example.com"
  }

  global {

  }

  rule first_rule is active {
    select when pageview ".*" setting ()
    // pre {   }
    notify("Hello Dev World", "Simple Dev rule.");
  }
}