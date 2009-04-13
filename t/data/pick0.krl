// pick in pre
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	   c = json.pick("$..doc");
	}     

	if nighttime() then
	   alert("You're coming from Idaho!") ;

    }
}
