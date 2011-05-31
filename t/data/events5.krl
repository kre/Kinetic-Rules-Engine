// composite events
ruleset 10 {
    rule test0 is active {
        select when web pageview "/2009/04/" setting(a) 
               not between(web pageview "/2009/05/",
		           web pageview "/2009/06/")
	noop();
    }
}
