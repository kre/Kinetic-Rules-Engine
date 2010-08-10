{
   "dispatch": [{"domain": "kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Testing the new appbuilder\n    ",
      "logging": "on",
      "name": "Test notify"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello"
            },
            {
               "type": "str",
               "val": "Kynetx"
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
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x214"
}
