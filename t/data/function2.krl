// function decl in pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    foo = function(a,b) {
                      fooz = 3;
		      boaz = "string";
		      foozle = (fooz * (a + b));
                      doc = <<Testing #{boaz} >>;
                      x
                  };
	}
        replace("test",("test" + foo));
    }
}
