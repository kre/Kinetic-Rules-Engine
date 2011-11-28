// test a bunch of expressions
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
        	minus_test = [1,0, -1,1.2,1.0001];
		}
		alert("Hello");

    }
}
