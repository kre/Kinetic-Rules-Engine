// string inequality
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
	if (page:var("zip") neq "83221") then
	   alert("You're not coming from Blackfoot!");

    }
}
