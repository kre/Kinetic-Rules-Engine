// composite events
ruleset 10 {
  meta {
  	author "MEH"
  	description <<
  		The rain in Spain stays mainly in the plain
  	>>
  }
  rule is_expression1 is active {
    select when web pageview 
	
		noop();
		notify("one","two");
	
    }
}
