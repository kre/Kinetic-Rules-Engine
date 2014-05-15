// range operator 
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	   c = x.pset(ent:foo{["flip"]});
	   c = x.pset(ent:foo);
	}     

	noop();

    }
}
