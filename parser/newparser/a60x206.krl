{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n    does it work?\n  ",
      "logging": "on",
      "name": "sidetab test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "test"
         }],
         "modifiers": null,
         "name": "sidetab",
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
      "pre": [{
         "lhs": "test",
         "rhs": " \n        <h1>Oh yeah!<\/h1>\n        <h2>Can you see me now?<\/h2>\n        <h3>Sure hope so.<\/h3>\n        <p>Weeee!!!<\/p>\n      ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x206"
}
