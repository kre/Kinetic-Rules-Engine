// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when pageview url.match(re/archives\/\d{4}/)
	{
		noop();
	}
    }
}
