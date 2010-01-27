// number less than
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if (page:var("price") < 15.99) then
	   alert("You're getting a bargain");

    }
}
