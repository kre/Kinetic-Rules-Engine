{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "www.frozengalaxy.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nA simple Hello World app   \n",
      "logging": "off",
      "name": "Hello World"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello World"
            },
            {
               "args": [
                  {
                     "type": "str",
                     "val": "Current Temp:"
                  },
                  {
                     "type": "var",
                     "val": "temp"
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
      "name": "hello",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "temp",
         "rhs": {
            "args": [],
            "predicate": "curr_temp",
            "source": "weather",
            "type": "qualified"
         },
         "type": "expr"
      }],
      "state": "active"
   }],
   "ruleset_name": "a632x1"
}
