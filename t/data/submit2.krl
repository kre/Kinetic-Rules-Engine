// submit event
ruleset 10 {
    rule test0 is active {
        select when web pageview "/(\d+)/" setting(x)
               then web submit "#formid" setting(myform)
               
	noop();
    }
}
