{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      \n    ",
      "logging": "on",
      "name": "BYU-I Book Comparison: Amazon Query"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Amazon Comparison"
            },
            {
               "args": [
                  {
                     "type": "str",
                     "val": "Results... "
                  },
                  {
                     "type": "array_ref",
                     "val": {
                        "index": {
                           "type": "num",
                           "val": 0
                        },
                        "var_expr": "arrayOfIsbn"
                     }
                  }
               ],
               "op": "+",
               "type": "prim"
            }
         ],
         "modifiers": [{
            "name": "sticky",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
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
      "name": "first_rule",
      "pagetype": {
         "event_expr": {
            "domain": "web",
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         },
         "foreach": []
      },
      "pre": [{
         "lhs": "arrayOfIsbn",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "isbn"
            }],
            "predicate": "var",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x240"
}
