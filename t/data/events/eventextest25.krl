// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when any 2 (
	pageview url re#www.windley.com#,
	pageview url re#/../a#,
	pageview url re#www.google.com#
	) 	
	{
		noop();
	}
    }
}
