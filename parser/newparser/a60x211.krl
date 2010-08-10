{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n    \n  ",
      "logging": "on",
      "name": "emit console"
   },
   "rules": [{
      "actions": [{"emit": "\n      console.log(\"wohoooo!\");  \n    "}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x211"
}
