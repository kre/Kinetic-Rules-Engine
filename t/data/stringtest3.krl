// strings with quotes quoted
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = "This is a string";
	    city = "This is a \"string\"";
	}     
        replace("test","test");
    }
}
