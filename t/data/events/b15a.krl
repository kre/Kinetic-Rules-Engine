// composite events
ruleset 1 {
    rule test0 is active {
	select when pageview url #custserv_page.html#
		before pageview url #homepage.html#
		within 3 hours
	{
		noop();
	}
    }
}
