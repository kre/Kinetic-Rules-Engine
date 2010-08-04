{
   "dispatch": [],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "testData",
      "source": "http://k-misc.s3.amazonaws.com/random/tree.json",
      "type": "dataset"
   }],
   "meta": {
      "logging": "off",
      "name": "Map Stuff (Azigo Stuff)"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "noop",
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
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x71"
}
