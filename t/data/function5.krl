// function decl in pre block
ruleset 10 {
    meta {
      use module a16x35 alias flipper
    }     
    rule test0 is active {
        select using "/test/" setting()
        replace("test",("test " + flipper:foo(3)));
    }
}
