ruleset a685x1 {
  meta {
    name "MostCrapOnOnePage"
    description <<
      This is a test app to put as much stuff on one pages as we can to verify as many actions as we can.
    >>
    author "Cid Dennis"
    // Uncomment this line to require Markeplace purchase to use this app.
    // authz require user
    logging off
  }

  dispatch {
    // Some example dispatch domains
    // www.exmple.com
    // other.example.com
  }

  global {

  }

  rule first_rule is active {
    select using ".*" setting ()
    pre {   }
    every {
      notify("Hello World", "This is a sample rule.") with sticky = true;
      append("#area9","added to area 9");
      prepend("#area9","prepend to area 9");
      after("#area9","<div id='area10'>data after area 9</div>");
      before("#area9","<div id='area8.5'>data before area 9</div>");
      float("absolute", "top: 10px", "right: 10px","http://k-misc.s3.amazonaws.com/runtime-dependencies/floattext.html");
      float_html("absolute", "top:50px", "right:50px", "<h1 id='floatid'>I'm Floating HTML!</h1>");
      move_after("#area4","#area2");
      move_to_top("#area5");
      replace_html("#area6","<div id='newarea6replace'>new area 6</div>");
      replace("#area7", "http://k-misc.s3.amazonaws.com/runtime-dependencies/replacetext.html");
      replace_inner("#area8", "The content has been replaced");
      replace_image_src("#myimage","http://k-misc.s3.amazonaws.com/runtime-dependencies/Asshole_20Watcher.jpg");
      set_element_attr("#mychangeelement","value","Ihavechanged");
    }
  }
}