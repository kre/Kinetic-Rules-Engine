{
   "dispatch": [{"domain": "example.com"}],
   "global": [{
      "lhs": "strings",
      "rhs": {
         "type": "array",
         "val": [
            {
               "type": "str",
               "val": "first element"
            },
            {
               "type": "str",
               "val": "second element"
            },
            {
               "type": "str",
               "val": "third element"
            }
         ]
      },
      "type": "expr"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\nTesting different ways of accessing arrays     \n",
      "logging": "on",
      "name": "Array access test"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "First Array Element"
               },
               {
                  "type": "var",
                  "val": "firstElement"
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
         "name": "array_in_global",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "firstElement",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$[0]"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "strings"
               },
               "type": "operator"
            },
            "type": "expr"
         }],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "First element from array in pre"
               },
               {
                  "type": "var",
                  "val": "first"
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
         "name": "array_in_pre",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "preStrings",
               "rhs": {
                  "type": "array",
                  "val": [
                     {
                        "type": "str",
                        "val": "first element"
                     },
                     {
                        "type": "str",
                        "val": "second element"
                     },
                     {
                        "type": "str",
                        "val": "third element"
                     }
                  ]
               },
               "type": "expr"
            },
            {
               "lhs": "first",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$[0]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "preStrings"
                  },
                  "type": "operator"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x144"
}
