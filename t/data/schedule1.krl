// testing postlude raise
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/(\d+)/\d+/" setting (year)

    noop();

    fired {
      schedule notification event foo repeat "3 3 3 3 *";
    } 

  }
}
