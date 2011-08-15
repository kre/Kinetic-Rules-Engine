// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview url #bar.html#
        and pageview url #foo.html#
	noop();
    }
}
