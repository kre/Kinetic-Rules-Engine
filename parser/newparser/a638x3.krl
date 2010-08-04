{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [],
   "meta": {
      "author": "Bart Elison",
      "description": " \n    Demo CU perc \n  ",
      "logging": "off",
      "name": "CU perc"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "search"
               },
               {
                  "type": "str",
                  "val": "uccu"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }},
         {"emit": "\n \n      function simple_percolation(obj) {\n      \n        return $K(obj).data(\"domain\").match(/uccu|macu.com|family1stcu/gi);\n         \n      }\n \n    "},
         {"action": {
            "args": [{
               "type": "var",
               "val": "simple_percolation"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "google.com|search.yahoo.com|bing.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a638x3"
}
