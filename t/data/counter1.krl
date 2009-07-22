// testing counters with a within filter
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
    }

    if counter.archive_pages > 2 within 3 days then 
      alert("You win the prize!  You've seen " + archive_pages + " pages from the archives!");


    fired {
      clear counter.archive_pages; 
    } else {
      counter.archive_pages += 1 from 1;  
    }


  }
}
