// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      key flippy "hello"

      provide keys dropbox to a16x151, a25x11
      provide keys flippy to a22x33

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
