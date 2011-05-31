// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when or (pageview url #fetch#,
				pageview url #flip#,
				pageview url #frick#)
	{
		noop();
	}
    }
}
