// ruleset has two rules
ruleset test0 {
    rule testa is active {
        select using "/test/" setting()

        replace("test","test");
    }
    rule testb is active {
        select using "/test/" setting()

        replace("test","test");
    }
}
