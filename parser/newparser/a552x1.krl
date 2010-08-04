{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "www.example.com"}
   ],
   "global": [],
   "meta": {
      "author": "Michael Farmer",
      "description": "\nDemo Application for Marketplace    \n",
      "logging": "off",
      "name": "Hello World"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Marketplace"
            },
            {
               "type": "str",
               "val": "My first app to sell on marketplace"
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
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a552x1"
}
