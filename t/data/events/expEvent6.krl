// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when pageview url re#/archives/\d{4}/# title re#phone#i
		noop();
    }
}
