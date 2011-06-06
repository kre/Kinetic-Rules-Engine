// composite events
ruleset 1 {
    rule test0 is active {
	select when pageview url #bar.html# 
       before pageview url #/archives/\d+/x.html# 
	noop();
    }
}
