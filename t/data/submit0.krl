// submit event
ruleset 10 {
    rule test0 is active {
        select when submit "#formid" setting(myform)
	noop();
    }
}
