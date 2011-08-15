// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview
             where url.extract(#/archives/(\d{4})/#) > 2003
	noop();
    }
}
