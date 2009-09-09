// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc =  cloudy() => 1 | 2;
	}     

	noop();
    }
}
 
