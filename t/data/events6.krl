// composite events
ruleset 10 {
    rule test0 is active {
        select when pageview "/2009/04/" setting(a) or
                    pageview "/2009/05/" setting(b)
	noop();
    }
}
