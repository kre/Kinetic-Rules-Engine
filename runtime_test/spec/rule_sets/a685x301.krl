ruleset a685x300 {
  meta {
    name "Test Annotate 2.0"
    description <<
      Normal inline annotate Test
    >>
    author "Cid Dennis"
    logging off
  }

  dispatch {
  }

  global {

  }

  rule first_rule is active {
    select using "google.com|bing.com/search|search.yahoo.com/search"  setting ()
    pre {   }
    every {

    emit <<

        function annotate_rentalcars(toAnnotate, wrapper, data) {

        wrapper.append("<div class="enterprise" style='border: 3px solid red'> " + data.discount +"</div>");

        wrapper.show();
    }
    >>;



      annotate:annotate("rentals") with    annotator = <| annotate_rentalcars |>
            and remote = "event";
    }

  }


  rule annotate_rentals is active {
    select when web annotate_search name "rentals" setting ()
      foreach annotate_data setting (akey,value)
      pre {
        annotate_instance = page:env("annotate_instance");
        annotate_data = page:env("annotatedata").as("json");
      }

      annotate:add_annotation_data(akey,{"discount":"10%" },annotate_instance);
   }
}