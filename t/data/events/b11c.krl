// composite events
ruleset event_after {
    rule test0 is active {
	select when pageview url #bar.html#
       		after phone inbound_call
	noop();
    }
}
