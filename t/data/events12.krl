// composite events
ruleset 10 {
    rule test0 is active {
//        select when location:new_pds_event "/2009/04/" setting(a
        select when location new_pds_event "/2009/04/" setting(a)
	noop();
    }
}
