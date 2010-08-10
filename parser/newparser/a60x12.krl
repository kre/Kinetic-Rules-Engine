{
   "dispatch": [{"domain": "byui.edu"}],
   "global": [],
   "meta": {
      "author": "Michael Grace",
      "description": "\nMaking BYUI better     \n",
      "logging": "on",
      "name": "BYUI Enhanced"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "w"
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
      "name": "registration_enhancement",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x12"
}
