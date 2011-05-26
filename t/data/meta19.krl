// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      key flippy "hello"

      errors to a16x88 version "prod"


    }

    global {
      z = bob:y.replace(re/world/, "Bob");
      z = alice:y.replace(re/world/, "Alice");
    }

    rule test0 is active {
        select using "/test/" setting()

	alert("hello");

    }
}
