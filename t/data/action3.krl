// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     
	
        notify("top-right", "#222", "#FFF", "Attention again!", true, "This is a test message.  You should be paying attention.  This one is sticky.");

    }
}
