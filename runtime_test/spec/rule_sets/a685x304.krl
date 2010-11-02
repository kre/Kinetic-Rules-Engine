Ruleset a685x304 {
  meta {
    name "Content Change Checker"
    description <<
    >>
    author ""
    logging off
  }

  dispatch {}

  global {}

  rule first_rule is active {
    select when pageview ".*" setting ()
    {
        content_changed("#res") with parameters = {"search_results":true};
    }
  }


  rule second_rule is active {
    select when web content_change search_results "true" setting ()
    {
      notify("Content Changed","second_rule from search reuslts");
      append("#res","some data second rule");
    }
  }


  rule third_rule is active {
    select when web content_change  search_results "false" setting ()
    {
        notify("Content Changed","third_rule");
    }
  }

}