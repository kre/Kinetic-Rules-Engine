ruleset 1 {
    rule test0 is active {
        select when 
                any 2 (
			pageview url #customer_support.html#,
			inbound_call to #801-649-4069#,
			email received subject #\[help\]#) 
		within 3 minutes
        {
                noop();
        }
    }
}

