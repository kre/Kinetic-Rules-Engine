ruleset 10 {
    rule test0 is active {
	select when car started where
   		(time:compare(timestamp,time:new("08:00:00")) < 0)
	{
		noop();
	}
    }
}
