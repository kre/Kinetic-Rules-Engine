{
   "dispatch": [{"domain": "kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Sam",
      "logging": "off",
      "name": "Testing App"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "not dual publishing!"
            },
            {
               "type": "str",
               "val": "and it works!"
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
   "ruleset_name": "a8x28"
}
