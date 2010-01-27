// function decl in pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    foo = function() { 
                    x
                  };
	}     
        replace("test",("test" + foo));
    }
}
