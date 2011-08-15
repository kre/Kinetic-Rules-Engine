ruleset 1 {
    rule test0 is active {
	select when count 4 (bank withdrawal where amount > 100) within 24 hours
                noop();
    }
}

