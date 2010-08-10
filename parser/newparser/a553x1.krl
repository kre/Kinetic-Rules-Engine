{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [],
   "meta": {
      "author": "Chris Featherstone",
      "description": "\nthis is a test application for rock climbing     \n",
      "logging": "off",
      "name": "testClimber"
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
         "pattern": "",
         "type": "prim_event",
         "vars": []
      }},
      "state": "inactive"
   }],
   "ruleset_name": "a553x1"
}
