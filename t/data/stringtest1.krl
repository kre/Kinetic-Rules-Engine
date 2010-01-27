// string equality
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	if (page:var("zip") eq "83221") then
	   alert("You're coming from Blackfoot!");

    }
}
