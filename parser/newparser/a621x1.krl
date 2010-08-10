{
   "dispatch": [{"domain": "nusion.com"}],
   "global": [],
   "meta": {
      "author": "David P. Hochman",
      "description": "\nTesting Kynetx features     \n",
      "logging": "off",
      "name": "Xtenyk First Steps"
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
               "val": "A message from a Kynetx rule."
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
      "name": "hello_world",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.nusion.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a621x1"
}
