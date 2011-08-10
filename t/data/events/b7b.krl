// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview #/(?:archives|logs)/(\d+)/(\d+)/#
        setting (year,month)
	noop();
    }
}
