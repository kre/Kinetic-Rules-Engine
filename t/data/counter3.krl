// testing counters
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
      c = app:page_counter;
    }

    alert("You're visitor number " + c + " to the archives!");

    fired {
      app:page_counter += 1 from 0;  
    } 


  }
}
