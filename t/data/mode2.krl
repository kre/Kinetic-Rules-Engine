// testing mode
ruleset 10 {
    rule test0 is test {
        select using "/test/" setting()
	noop();
    }
}
