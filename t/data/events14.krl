// composite events
ruleset 10 {
    rule test0 is active {
        select when http delete status_code "(2\d\d)" label "subscription_deleted" setting (status)
	noop();
    }
}
