// make sure clownhats return the right stuff
ruleset a60x485 {
  meta {
    name "emit-clownhat-bug-test"
    author "Mike Grace"
    description <<
      emit-clownhat-bug-test
    >>
    logging on
  }

  rule first_rule {
    select when web pageview ".*"
    pre {
      x = <|
         var userId = /\/users\/([0-9]*)\//.exec("/users/230948/coolio")[1];
         alert(userId);
      |>;
    }
    noop();
  }

}
