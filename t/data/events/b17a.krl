ruleset 1 {
    rule test0 is active {
	select when any 2 (web pageview url #customer_support.htm#,
		phone inbound_call to #801-649-4069#,
		email received subject #\[help\]#)
        {
                noop();
        }
    }
}

