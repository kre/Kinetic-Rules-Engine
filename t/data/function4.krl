// function decl in pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    foo = function(a) {
                      x = a + 5;
                      4 * x
                  };
	}     
        replace("test","test " + foo(3));
    }
}
