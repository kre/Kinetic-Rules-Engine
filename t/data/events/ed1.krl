// Ed select statement
ruleset 10 {
  rule ed1 is active {
    select when explicit news_search or web news_search
    noop();

  }
}
