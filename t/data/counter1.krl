// testing counters with a within filter
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
    }

    if ent:archive_pages > 2 within 3 days then 
      alert("You win the prize!  You've seen " + ent:archive_pages + " pages from the archives!");


    fired {
      clear ent:archive_pages; 
    } else {
      ent:archive_pages += 2 from 1;  
    }


  }
}
