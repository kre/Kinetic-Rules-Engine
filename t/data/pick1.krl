// pick in in pre with datasource
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	   c = datasource:fizzle("q=foo").pick("$..doc");
	}     

	if time:nighttime() then
	   alert("You're coming from Idaho!") ;

    }
}
