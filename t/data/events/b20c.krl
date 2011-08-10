ruleset 1 {
    rule test0 is active {
        select when count 5 (withdrawal amount #$(\d+\.\d\d)#) sum(m)
                noop();
    }
}

