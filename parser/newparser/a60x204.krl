{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n    Using logging to help debug Kynetx applications and how to use it.\n  ",
      "logging": "off",
      "name": "Turning logging on"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "logging"
            },
            {
               "type": "str",
               "val": "Rulz"
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
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x204"
}
