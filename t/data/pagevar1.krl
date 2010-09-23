// A simple page variable in query
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	if (page:var("zip") like "83*") then
	   alert("You're coming from Idaho!");

    }
}
