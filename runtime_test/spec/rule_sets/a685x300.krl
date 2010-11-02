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
        if (data.domain == "www.enterprise.com") {
          wrapper.append("<div class="enterprise" style='border: 3px solid red'>Enterprise Found</div>");
          wrapper.show();
        }
       }
    >>;


    annotate:annotate("rentals") with annotator = <| annotate_rentalcars |>;
    }
  }
}