// range operator 
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	   c = x.range(15).length();
	}     

	noop();

    }
}
