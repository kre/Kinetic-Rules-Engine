// number greater than
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	if (page:var("total") > 99.99) then
	   alert("You qualify for free shipping!");

    }
}
