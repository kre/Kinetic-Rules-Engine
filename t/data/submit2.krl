// submit event
ruleset 10 {
    rule test0 is active {
        select when pageview "/(\d+)/" setting(x)
               then submit "#formid" setting(myform)
               
	noop();
    }
}
