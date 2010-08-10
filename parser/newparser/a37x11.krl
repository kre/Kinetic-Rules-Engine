{
   "dispatch": [{"domain": "zappos.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Https Test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "str",
            "val": "hello world"
         }],
         "modifiers": null,
         "name": "alert",
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
      "name": "sample",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a37x11"
}
