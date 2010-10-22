// testing mode
ruleset 10 {
    rule test0 {
        select using "/test/" setting()
	noop();
    }
}
