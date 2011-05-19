// composite events
ruleset 1 {
    rule test0 is active {
        select when pageview where url.match("foop") and pageview #foop#
		
	noop();
    }
}
