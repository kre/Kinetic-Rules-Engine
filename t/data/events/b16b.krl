ruleset 1 {
    rule test0 is active {
	select when car started 
		before at(time:new("08:00:00"))
        {
                noop();
        }
    }
}

