// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = (cloudy() || sunny()) => ("foo" + x.pick("$..foo")) | "fizz";
	}     

	noop();
    }
}
 
