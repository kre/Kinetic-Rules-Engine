{
   "dispatch": [{"domain": "tnt-creations.com"}],
   "global": [],
   "meta": {
      "description": "\nHello World Tutorial     \n",
      "logging": "off",
      "name": "Hello World"
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
               "val": "TNT Creations with Thomas and Kaisa Lee"
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
      "name": "my_first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.tnt-creations.com/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a648x2"
}
