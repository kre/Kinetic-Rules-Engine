{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "alert"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "str",
            "val": "KOBJ_alert"
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
      "name": "alert",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x37"
}
