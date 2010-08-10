{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "Function that totals values in array"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Test"
            },
            {
               "type": "var",
               "val": "test"
            }
         ],
         "modifiers": null,
         "name": "notify",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "increment",
            "rhs": {
               "expr": {
                  "args": [
                     {
                        "type": "var",
                        "val": "x"
                     },
                     {
                        "type": "num",
                        "val": 1
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               },
               "type": "function",
               "vars": ["x"]
            },
            "type": "expr"
         },
         {
            "lhs": "test",
            "rhs": {
               "args": [{
                  "type": "num",
                  "val": 1
               }],
               "function_expr": {
                  "type": "var",
                  "val": "increment"
               },
               "type": "app"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x161"
}
