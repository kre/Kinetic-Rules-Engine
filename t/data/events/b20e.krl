ruleset 1 {
    rule test0 is active {
        select when repeat 5 (withdrawal amount #$(\d+\.\d\d)#) push(m)
                noop();
    }
}

