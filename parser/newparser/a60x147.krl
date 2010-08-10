{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "String Comparison"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "'same' == 'same'?"
               },
               {
                  "type": "var",
                  "val": "shouldBeSame"
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
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "'different' == 'yes'?"
               },
               {
                  "type": "var",
                  "val": "shouldBeDifferent"
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
      "name": "simple_string_compare_using_function",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "isSame",
            "rhs": {
               "expr": {
                  "args": [
                     {
                        "type": "var",
                        "val": "string1"
                     },
                     {
                        "type": "var",
                        "val": "string2"
                     }
                  ],
                  "op": "==",
                  "type": "ineq"
               },
               "type": "function",
               "vars": [
                  "string1",
                  "string2"
               ]
            },
            "type": "expr"
         },
         {
            "lhs": "convertBool",
            "rhs": {
               "expr": null,
               "type": "function",
               "vars": ["num"]
            },
            "type": "expr"
         },
         {
            "lhs": "same",
            "rhs": {
               "args": [
                  {
                     "type": "str",
                     "val": "same"
                  },
                  {
                     "type": "str",
                     "val": "same"
                  }
               ],
               "function_expr": {
                  "type": "var",
                  "val": "isSame"
               },
               "type": "app"
            },
            "type": "expr"
         },
         {
            "lhs": "different",
            "rhs": {
               "args": [
                  {
                     "type": "str",
                     "val": "different"
                  },
                  {
                     "type": "str",
                     "val": "yes"
                  }
               ],
               "function_expr": {
                  "type": "var",
                  "val": "isSame"
               },
               "type": "app"
            },
            "type": "expr"
         },
         {
            "lhs": "shouldBeSame",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "same"
               }],
               "function_expr": {
                  "type": "var",
                  "val": "convertBool"
               },
               "type": "app"
            },
            "type": "expr"
         },
         {
            "lhs": "shouldBeDifferent",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "different"
               }],
               "function_expr": {
                  "type": "var",
                  "val": "convertBool"
               },
               "type": "app"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x147"
}
