ruleset 1 {
    rule test0 is active {
	select when bank deposit amount #(\d+)# setting(dep_amt)
		before bank withdrawal where amount > dep_amt || amount > 100
                noop();
    }
}

