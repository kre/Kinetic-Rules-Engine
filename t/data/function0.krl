// function decl in pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    foo = function(a,b) {
                      x = 3 + a * b;
                      x
                  };
	}     
        replace("test","test" + foo);
    }
}
