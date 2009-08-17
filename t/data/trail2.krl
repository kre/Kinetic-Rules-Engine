// testing trails
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/\d+/\d+/" setting ()

    pre {
       t = current ent:my_trail;
       x = history 1 ent:another_trail;
    }

    if seen "/archive/2006" after "/archive/2007" in ent:my_trail then 
      alert("You win the prize!  You've seen " + t);

    fired {
      forget "/archive/2006" in ent:my_trail;
    } else {
      mark ent:my_trail with x;
    }

  }
}
