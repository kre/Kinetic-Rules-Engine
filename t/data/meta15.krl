// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      provide [x,y,flipper]

    }

    global {
      x = 5;
      y = "Hello World";
      flipper = function() {5};
    }

    rule test0 is active {
        select using "/test/" setting()

	alert("hello");

    }
}
