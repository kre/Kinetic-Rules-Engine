// composite events
ruleset 10 {
    rule test0 is active {
        select when web pageview "/2009/04/" setting(a) then
                    web pageview "/2009/05/" setting(b) then
                    web pageview "/2009/05/" 
	noop();
    }
}
