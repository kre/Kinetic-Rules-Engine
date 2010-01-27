// number greater than or equal
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if (page:var("total") >= 100) then
	   alert("You qualify for free shipping!");

    }
}
