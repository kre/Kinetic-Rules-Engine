ruleset 1 {
    rule test0 is active {
	select when bank withdrawal where amount > 100
                noop();
    }
}

