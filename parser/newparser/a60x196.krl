{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": " \n    experiment for devex question \n  ",
      "logging": "on",
      "name": "Mutable variables in looping rule"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "What is it now?"
            },
            {
               "type": "var",
               "val": "mutableVar"
            }
         ],
         "modifiers": [{
            "name": "stick",
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
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "mutableVar",
         "rhs": {
            "args": [
               {
                  "type": "var",
                  "val": "mutableVar"
               },
               {
                  "type": "num",
                  "val": 1
               }
            ],
            "op": "+",
            "type": "prim"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x196"
}
