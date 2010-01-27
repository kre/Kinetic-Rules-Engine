// logging pragma in meta block
ruleset 10 {

    meta {
      description <<
      Ruleset for testing something or other.
      >>
      logging on
    }

    rule test0 is active {
        select using "/test/" setting()

      alert("hello");

    }
}
