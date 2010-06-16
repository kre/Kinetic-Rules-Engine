// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      use module a61x59 alias frog
      use module a61x60

    }

    rule test0 is active {
        select using "/test/" setting()

	alert("hello");

    }
}
