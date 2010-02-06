// pick in pre
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	   c = json.tail().length();
	}     

	alert("You're coming from Idaho!") ;

    }
}
