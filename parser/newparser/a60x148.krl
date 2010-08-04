{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "String Like Comparison using functions"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "wow == wow?"
            },
            {
               "type": "var",
               "val": "msg"
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
      "name": "compare_strings_using_like_function",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "stringLike",
            "rhs": {
               "expr": null,
               "type": "function",
               "vars": ["string"]
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "wow"
               }],
               "function_expr": {
                  "type": "var",
                  "val": "stringLike"
               },
               "type": "app"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x148"
}
