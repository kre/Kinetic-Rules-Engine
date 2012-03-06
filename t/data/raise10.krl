// testing postlude raise
ruleset 10 {
  rule frequent_archive_visitor is active {
    select using "/archives/(\d+)/\d+/" setting (year)
      foreach flupp setting (x)

      noop();

      fired {
        raise explicit event ("foo"+"bar") with
           x = 5 and
           y = "hello"
         on final;

    } 

  }
}
