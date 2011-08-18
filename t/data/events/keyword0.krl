// action keywords
ruleset 10 {
    rule test0 is active {
	select when pageview url #bar.html#
         or phone inbound_call from #801\d+#
     pre {
     	foo = << html string >>;
     }
     
		after("#id_tag",foo);
	 
    }
}
