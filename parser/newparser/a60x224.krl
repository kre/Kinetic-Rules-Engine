{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": " for devex question ",
      "logging": "off",
      "name": "replace inner not saving"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#ghead"
            },
            {
               "type": "str",
               "val": "<h1>All your navigation bar belongs to us!<\/h1>"
            }
         ],
         "modifiers": null,
         "name": "replace_inner",
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
      "name": "replace_me_already",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x224"
}
