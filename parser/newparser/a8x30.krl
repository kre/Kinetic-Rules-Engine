{
   "dispatch": [{"domain": "www.baconsalt.com"}],
   "global": [],
   "meta": {
      "description": "\ntesting let_it_snow   \n",
      "logging": "off",
      "name": "snowing"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "let_it_snow",
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
      "name": "snow",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x30"
}
