// adding modifiers to action
ruleset 10 {
  rule special_mods {
    select when foo bar 

    noop();

    always {
      raise notification event status 
        with _api = "sky" and
             _rids = ["a16x38"];
    }
  }

}
