// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting(gp)

	pre {
          foo = {"foo": ("bar" + gp),
                 "fizz": 3
	        };
        }

	notify(foo);
    }
}
