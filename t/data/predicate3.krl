// predicates conjunction
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if time:nighttime() then
	   alert("You're coming from Idaho!") ;

    }
}
