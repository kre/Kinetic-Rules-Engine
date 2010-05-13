// mail events
ruleset 10 {
    rule test0 is active {
        select when mail sent setting(x)
	noop();
    }
}
