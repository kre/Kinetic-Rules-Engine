// composite events
ruleset 1 {
    rule test0 is active {
	select when pageview url #bar.html# 
        and pageview url #/archives/\d+/foo.html# 
	{
		noop();
	}
    }
}
