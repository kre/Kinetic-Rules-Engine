{
   "dispatch": [
      {"domain": "www.facebook.com"},
      {"domain": "search.creativecommons.org"},
      {"domain": "www.kynetx.com"}
   ],
   "global": [],
   "meta": {
      "author": "",
      "description": "\n      \n    ",
      "logging": "on",
      "name": "www test"
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
   "ruleset_name": "a60x235"
}
