// directives and raw actions
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

        directive("say") with
	  msg = "Hello World" and
          v = <|$K("#foo").append("3")|>;

    }

}
