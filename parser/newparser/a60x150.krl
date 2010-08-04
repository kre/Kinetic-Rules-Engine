{
   "dispatch": [{"domain": "twitter.com"}],
   "global": [{
      "lhs": "testArray",
      "rhs": {
         "type": "array",
         "val": [{
            "type": "str",
            "val": "a"
         }]
      },
      "type": "expr"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\nfiltering through the trash my tracking twitter relationships    \n",
      "logging": "on",
      "name": "Twitter Relationships"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "working"
            },
            {
               "type": "str",
               "val": "w"
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
      "state": "active"
   }],
   "ruleset_name": "a60x150"
}
