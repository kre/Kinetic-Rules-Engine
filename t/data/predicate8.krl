// predicates disjunction
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if ((page:var("total") > 99.99) && weather:today_windy()) then
	   alert("A windy shopping trip!");

    }
}
