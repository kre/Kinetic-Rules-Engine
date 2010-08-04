{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "author": "MikeGrace",
      "description": "\ntesting for what characters result in an infocard not working     \n",
      "logging": "on",
      "name": "Invalid char test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "I'm working!"
            },
            {
               "type": "str",
               "val": "You can't break me! : )"
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
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x63"
}
