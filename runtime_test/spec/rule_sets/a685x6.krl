ruleset a685x6 {
  meta {
    name "RaiseEventTwo"
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

   rule second_rule is active {
    select when web testevent setting ()
    {
        notify("second_rule","second_rule") with sticky = true;
        emit <<
              var app = KOBJ.get_application("a685x5");
              app.raise_event("cidtest",{"testcid":"bob"});
        >>;
    }
    }

}