{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "str",
            "val": "Hi!"
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "google.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x86"
}
