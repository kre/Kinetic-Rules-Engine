// number equality
ruleset 10 {
    rule test0 is active {
        select using "/test/" 

	if (page:var("price") == 15.99) then
	   alert("You're getting a bargain");

    }
}
