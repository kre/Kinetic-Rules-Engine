ruleset a685x5 {
  meta {
    name "RaiseEvent"
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
    {
        raise_event("testevent") with parameters = {"aaa":"bbb","ccc":"dddd"} and app_id = "a685x6";
    }
   }

     rule third_rule is active {
    select when web cidtest setting ()
    {
        notify("third_rule","third_rule") with sticky = true;
    }

  }

}