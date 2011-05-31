// composite events
ruleset 1 {
    rule test0 is active {
	select when pageview url #bar.html# 
       between ( pageview url #/archives/\d+/x.html#,
		pageview url #/archives/\d+/y.html# setting (a)
	  )
	noop();
    }
}
