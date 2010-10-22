// testing mode
ruleset 10 {
    rule test0 is inactive {
        select using "/test/" setting()
	noop();
    }
}
