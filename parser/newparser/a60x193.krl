{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": " \n    Showing off how I setup a Kynetx app. \n  ",
      "logging": "on",
      "name": "Example App Setup"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "hello"
            },
            {
               "type": "str",
               "val": "world"
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
   "ruleset_name": "a60x193"
}
