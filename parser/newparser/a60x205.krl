{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n    Setting up an app to quickly prototype javascript for Kynetx applications\n  ",
      "logging": "off",
      "name": "kQuery"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "$K is now available to use"
            },
            {
               "type": "str",
               "val": ": )"
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
   "ruleset_name": "a60x205"
}
