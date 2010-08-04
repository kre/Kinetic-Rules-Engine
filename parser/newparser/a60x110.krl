{
   "dispatch": [
      {"domain": "kynetx.com"},
      {"domain": "example.com"}
   ],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "status bar test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "str",
            "val": "<h1>Hi mom!<\/h1>"
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x110"
}
