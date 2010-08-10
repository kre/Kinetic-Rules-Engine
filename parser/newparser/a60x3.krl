{
   "dispatch": [{"domain": "www.xkcd.com"}],
   "global": [],
   "meta": {
      "description": "\n      sandbox during conf   \n    ",
      "logging": "off",
      "name": "conf"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello world"
            },
            {
               "type": "str",
               "val": "awesome!"
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
      "name": "holla",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "6",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x3"
}
