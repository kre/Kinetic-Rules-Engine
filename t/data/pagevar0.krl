// A simple page variable in pre block
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    zip = page:var("zip");
	}     
	alert("hello");
    }
}
