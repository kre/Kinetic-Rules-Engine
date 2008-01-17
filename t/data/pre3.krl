// declaration with variables
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	    current_price = stocks:last("^DJI");
	    current_price = stocks:last("^DJI","foo");
	}     
        replace("test","test");
    }
}
