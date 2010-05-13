// submit event
ruleset 10 {
    rule test0 is active {
        select when web submit "#formid" on "/archives/2006" setting(my_form)
	noop();
    }
}
