{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "Function sandbox"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "15 + 5 is ..."
            },
            {
               "type": "var",
               "val": "newnum"
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
            "lhs": "add5",
            "rhs": {
               "expr": {
                  "args": [
                     {
                        "type": "var",
                        "val": "x"
                     },
                     {
                        "type": "num",
                        "val": 5
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
            "lhs": "newnum",
            "rhs": {
               "args": [{
                  "type": "num",
                  "val": 15
               }],
               "function_expr": {
                  "type": "var",
                  "val": "add5"
               },
               "type": "app"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x136"
}
