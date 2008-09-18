// A simple page variable existence test
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if page:exists("zip") then
	   alert("The zip was set");

    }
}
