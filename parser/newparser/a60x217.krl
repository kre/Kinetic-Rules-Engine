{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      How to easily and quickly use ErrorStack to monitor your apps for breakage.\n    ",
      "logging": "on",
      "name": "ErrorStack Rocks!"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "ErrorStack"
            },
            {
               "type": "str",
               "val": "For the win!"
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
   "ruleset_name": "a60x217"
}
