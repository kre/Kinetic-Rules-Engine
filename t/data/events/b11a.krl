// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview url #bar.html#
       		before phone inbound_call
	noop();
    }
}
