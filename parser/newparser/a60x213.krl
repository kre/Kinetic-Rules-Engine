{
   "dispatch": [{"domain": "geekif.tumblr.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      for kynetx tut\n    ",
      "keys": {"errorstack": "0ad469158cd234f6ed013c9edcfe5abb"},
      "logging": "on",
      "name": "pre errorstack tut test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello World"
            },
            {
               "type": "str",
               "val": "This is a sample rule."
            }
         ],
         "modifiers": null,
         "name": "notify",
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
   "ruleset_name": "a60x213"
}
