// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview url #/archives/\d{4}/#
                     title #iphone#i
	noop();
    }
}
