// composite events
ruleset 1 {
    rule test0 is active {
        select when pageview ".*"
		between(at(time:new("08:00:00")),
			at(time:new("17:00:00")))
	noop();
    }
}
