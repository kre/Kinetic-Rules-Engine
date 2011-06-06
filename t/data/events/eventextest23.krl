// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when repeat 5 (pageview url #fetch/(\.+)#) push(m)	{
		noop();
	}
    }
}
