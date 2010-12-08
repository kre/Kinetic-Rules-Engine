// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      key flippy "hello"

      use module a16x78 alias bob
          with p = 10 and
               q = key:flippy()


      use module a16x78 alias alice
          with p = 11 and
               q = key:floppy()


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
