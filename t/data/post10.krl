// testing postlude control statements
ruleset 10 {
  rule frequent_archive_visitor  {
    select when foo bar

    noop();

    fired {
      set ent:foo 3
    } 

  }
}
