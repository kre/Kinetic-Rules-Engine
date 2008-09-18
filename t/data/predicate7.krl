// predicates disjunction
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if not (nighttime() || today_windy()) then
	   alert("You're coming from Idaho!");

    }
}
