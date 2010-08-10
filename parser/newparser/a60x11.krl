{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "author": "Michael Grace",
      "description": "\ngoogle test     \n",
      "logging": "on",
      "name": "google test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Card Selector"
            },
            {
               "type": "str",
               "val": "Working!"
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
      "name": "notify",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x11"
}
