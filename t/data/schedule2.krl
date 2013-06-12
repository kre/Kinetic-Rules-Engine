// testing postlude raise
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/(\d+)/\d+/" setting (year)

    noop();

    fired {
      schedule notification event foosh at time:add(time:now(),{"minutes" : 1})
   	with 
     		x = 5 and
     		y = 6;
    } 

  }
}
