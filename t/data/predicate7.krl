// predicates disjunction
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	if (not (time:nighttime() || weather:today_windy())) then
	   alert("You're coming from Idaho!");

    }
}
