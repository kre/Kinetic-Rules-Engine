{
   "dispatch": [{"domain": "baconsalt.com"}],
   "global": [],
   "meta": {
      "description": "\nSimple notification app   \n",
      "logging": "off",
      "name": "Tutorial"
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
      "name": "my_first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "",
         "type": "prim_event",
         "vars": []
      }},
      "state": "inactive"
   }],
   "ruleset_name": "a9x18"
}
