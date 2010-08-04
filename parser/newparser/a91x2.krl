{
   "dispatch": [{"domain": "protoven.com"}],
   "global": [],
   "meta": {
      "description": "\nSimple notification app     \n",
      "logging": "off",
      "name": "Tutorial"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hey All"
            },
            {
               "type": "str",
               "val": "Protoven works hard"
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://protoven.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a91x2"
}
