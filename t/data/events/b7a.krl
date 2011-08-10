// composite events
ruleset 10 {
    rule test0 is active {
	select when mail received from #(.*)@windley.com#
  setting(user_id)
	noop();
    }
}
