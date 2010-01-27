// testing counters
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
      c = ent:archive_pages;
    }

    if (ent:archive_pages > 2) then 
      alert(("You win the prize!  You've seen " + (c + " pages from the archives!")));

    fired {
      clear ent:archive_pages; 
    } else {
      ent:archive_pages += 1 from 1;  
    }


  }
}
