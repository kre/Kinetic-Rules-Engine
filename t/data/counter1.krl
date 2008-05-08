// testing counters with a within filter
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
      c = counter.archive_pages;
    }

    if counter.archive_pages > 2 within 3 days then 
      alert("You win the prize!  You've seen " + c + " pages from the archives!");


    fired {
      clear counter.archive_pages; 
    } else {
      counter.archive_pages += 1 from 1;  
    }


  }
}
