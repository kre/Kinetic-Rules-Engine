{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Bar Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "str",
            "val": "<h1>hello world<\/h1>"
         }],
         "modifiers": null,
         "name": "status_bar",
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
      "name": "bar_test",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x61"
}
