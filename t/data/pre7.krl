// no pre
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
	if daytime() then 
         replace("test","test");
    }
}
