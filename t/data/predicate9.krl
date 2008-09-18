// predicates disjunction
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

	if (page:var("total") > 99.99 && location:zip() like "83*") then
	   alert("A big spender from Idaho!");

    }
}
