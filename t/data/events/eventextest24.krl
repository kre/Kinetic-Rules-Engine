// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when at("noon")
	{
		noop();
	}
    }
}
