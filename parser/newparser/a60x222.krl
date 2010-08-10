{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Using tracking services to learn more about how your app is being used and how to better serve your users.\n    ",
      "logging": "off",
      "name": "App Statistics Tracking"
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
   "ruleset_name": "a60x222"
}
