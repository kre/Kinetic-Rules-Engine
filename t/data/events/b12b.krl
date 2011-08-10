// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview url #mid.html#
		not between(pageview url #(\d+).html# setting(b),
			pageview url #(\d+).html# setting(c))
	noop();
    }
}
