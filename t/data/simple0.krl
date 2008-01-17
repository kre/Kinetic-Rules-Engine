// simple rule with numeric ruleset name
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre { // empty pre block
        } 
        replace("test","test");
    }
}
