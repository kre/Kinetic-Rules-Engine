// adding modifiers to action
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

       a_label =>	
        twitter:authorize("This is a message");

    }
}
