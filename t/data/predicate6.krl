// predicates conjunction and disjunction
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if not ((tomorrow_windy() || nighttime()) && today_windy()) then
	   alert("You're coming from Idaho!");

    }
}
