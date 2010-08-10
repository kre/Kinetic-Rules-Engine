{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "description": "\nMy New App Description     \n",
      "logging": "off",
      "name": "My New App"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "hello"
            },
            {
               "type": "str",
               "val": "first rule yay!"
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
      "name": "rule1",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.google.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a39x1"
}
