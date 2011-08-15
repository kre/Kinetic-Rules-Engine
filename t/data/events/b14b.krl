// composite events
ruleset 1 {
    rule test0 is active {
        select when at(time:new("08:00:00"))
	noop();
    }
}
