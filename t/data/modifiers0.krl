// adding modifiers to action
ruleset 10 {
  rule float2 is inactive {
    select using "/identity-policy/" setting ()

    float("absolute", "top: 10px", "left: 10px",
          "http://127.0.0.1/test.html")
        with delay = 0 and
             draggable = false and
             scrollable = false and
             effect = "appear";
  }

}
