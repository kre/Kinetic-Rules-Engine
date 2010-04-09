// submit event
ruleset 10 {
    rule test0 is active {
        select when web:submit "#formid" setting(myform)
	noop();
    }
}
