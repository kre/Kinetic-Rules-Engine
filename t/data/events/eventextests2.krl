// composite events
ruleset 1 {
    rule test0 is active {
        select when web pageview;	
	noop();
    }
}