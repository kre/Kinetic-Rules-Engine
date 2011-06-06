// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when then (pageview url #fetch#,
				pageview url #flip#,
				pageview url #frick#)
	{
		noop();
	}
    }
}
