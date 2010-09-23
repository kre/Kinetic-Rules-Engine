// adding name to meta
ruleset 10 {

    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>
      use css resource jquery_ui_dark
      use javascript resource "http://www.windley.com/foo.js"


    }

    rule test0 is active {
        select using "/test/" setting()

	alert("hello");

    }
}
