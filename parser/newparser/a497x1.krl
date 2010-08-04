{
   "dispatch": [{"domain": "gaiaonline.com"}],
   "global": [],
   "meta": {
      "author": "Draconissa",
      "description": "\nalerts me if gaia page has an egg to click     \n",
      "logging": "off",
      "name": "GaiaEaster"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Egg Found!"
            },
            {
               "type": "str",
               "val": "There is an easter egg found on this page"
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
      "name": "eastereggfound",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.gaiaonline.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a497x1"
}
