ruleset a685x7 {
  meta {
    name "SimpleNotify"
    description <<

    >>
    author "cid"
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
    notify("Hello prod World", "Hello prod World") with sticky = true;

  }
}