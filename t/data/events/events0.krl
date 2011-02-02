// composite events
ruleset 10 {
    rule test0 is active {
        select when pageview "/2009/04/" setting(a)
	noop();
    }
}
