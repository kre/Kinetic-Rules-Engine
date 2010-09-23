// composite events
ruleset 10 {
    rule test0 is active {
        select when web click "#my_id"
	noop();
    }
}
