{
   "dispatch": [],
   "global": [],
   "meta": {},
   "rules": [{
      "actions": null,
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [[{
         "expr": {
            "type": "var",
            "val": "maps"
         },
         "var": ["map"]
      }]],
      "name": "findmap",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x43"
}
