// composite events
ruleset 10 {
  rule is_custom_event is active {
    select when eThrow foo "bar"
	noop();
    }
}
