ruleset a685x10 {
  meta {
    name "ContentChangeTest"
    description <<

    >>
    author ""
    logging off
  }

  dispatch {
  }

  global {

  }

  rule first_rule is active {
    select when pageview ".*" setting ()
    {
      content_changed("#other_changed") with parameters = {"other_change":"true"};
      append("body","<div id='fired'></div>");
    }
  }

  rule second_rule is active {
    select when web content_change other_change "true" setting ()
    {
      append("#change_result","second_rule_fired");
    }
  }

  rule third_rule is active {
    select when web content_change setting ()
    {
      append("#change_result2","third_rule_fired");
    }
  }

}