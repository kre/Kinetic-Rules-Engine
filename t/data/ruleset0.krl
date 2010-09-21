// ruleset name is alphanum
ruleset test0 {
    rule test0 is active {
        select using "/test/" setting()
        replace("test","test");
    }
}
