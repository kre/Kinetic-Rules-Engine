// pick in in predicate
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	   c = datasource:fizzle("q=foo");
	}     

	if (c.pick("$..doc[0]") eq "3") then
	   alert("You're coming from Idaho!") ;

    }
}
