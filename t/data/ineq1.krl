// number inequality
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
	if (page:var("price") != 15.99) then
	   alert("The price has changed") ;

    }
}
