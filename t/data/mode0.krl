// testing mode
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
	noop();
    }
}
