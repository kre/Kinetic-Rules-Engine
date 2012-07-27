// testing guard statement
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/(\d+)/\d+/" setting (year)
    noop();
    fired {
        clear ent:alist on final;
    } 
  }
}
