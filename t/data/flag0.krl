// testing flags
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
      c = ent:been_here;
    }

    if ent:been_here then 
      alert("You win the prize!");

    fired {
      clear ent:been_here; 
    } else {
      set ent:been_here;
    }


  }
}
