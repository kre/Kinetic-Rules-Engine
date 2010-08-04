{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Jason Rice",
      "description": "\n      Perc. radio shack search results to the top of the page.\n    ",
      "logging": "on",
      "name": "Radio Shack"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "simple_percolation"
         }],
         "modifiers": null,
         "name": "percolate",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\n        function simple_percolation(obj) { \n            if ($K(obj).data(\"domain\") == \"radioshack.com\") {\n              console.log($K(obj).data(\"domain\"));\n              return true;\n            }else {\n              return false\n            }\n         }\n      ",
      "foreach": [],
      "name": "small_percolation",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "google.com|search.yahoo.com|bing.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a691x3"
}
