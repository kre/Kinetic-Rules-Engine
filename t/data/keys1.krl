// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	pre {
          foo = {"foo": "bar",
                 "fizz": 3
	        };
	      bar = foo.keys();
        }

	notify(foo);
    }
}
