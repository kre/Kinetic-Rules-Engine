{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "FlippyLoo"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "test",
         "source": "jquery_ui"
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
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [],
      "state": "active"
   }],
   "ruleset_name": "a93x10"
}
