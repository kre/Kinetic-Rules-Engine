// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	notify({"foo": "bar",
                "fizz": 3
	       });
    }
}
