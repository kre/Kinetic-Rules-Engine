// using regular expressions
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    my_str = "This is a string";
	    new_str = my_str.replace(re/string/g,"puppy");
	}
	alert(new_str);
    }
}
