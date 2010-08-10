{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "Number comparison"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Tries"
            },
            {
               "type": "var",
               "val": "msg"
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
      "name": "compare_a_number",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "equal",
            "rhs": {
               "expr": null,
               "type": "function",
               "vars": [
                  "num",
                  "tries"
               ]
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": {
               "args": [
                  {
                     "type": "num",
                     "val": 3
                  },
                  {
                     "type": "num",
                     "val": 0
                  }
               ],
               "function_expr": {
                  "type": "var",
                  "val": "equal"
               },
               "type": "app"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x146"
}
