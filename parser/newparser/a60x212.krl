{
   "dispatch": [{"domain": "devex.kynetx.com"}],
   "global": [{
      "content": "\n      #container * {\n        display: none;\n      }\n    ",
      "type": "css"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      changing the css on a page.\n    ",
      "logging": "off",
      "name": "CSS Master!"
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
   "ruleset_name": "a60x212"
}
