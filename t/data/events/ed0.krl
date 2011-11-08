// Ed select statement
ruleset 10 {
  rule ed0 is active {
    select when click ".panelNavAdd.*"
	noop();
  }
}
