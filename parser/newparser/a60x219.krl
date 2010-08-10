{
   "dispatch": [{"domain": "tumblr.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Track your application to learn more about how it is being used to optimize it and learn.\n    ",
      "logging": "on",
      "name": "App Tracking"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Tumblr Rocks!"
            },
            {
               "type": "str",
               "val": ""
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
      "name": "notify_me",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x219"
}
